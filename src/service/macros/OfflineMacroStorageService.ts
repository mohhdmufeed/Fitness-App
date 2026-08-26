import {DailyMacros, DailySummary} from '@data/models/DailyMacros'
import {createEmptyMacroTotals, MacroTargets, MacroTotals} from '@data/models/Macros'
import {Meal} from '@data/models/Meal'
import {InputMethodEnum, LogMealEntryPayload, MealEntry, UpdateMealEntryPayload} from '@data/models/MealEntry'
import getDatabase from '@service/database/sqliteDatabase'
import AsyncStorage from '@react-native-async-storage/async-storage'

const MACRO_TARGETS_KEY = 'kf_macro_targets'
const DEFAULT_TARGETS: MacroTargets = {
  calories: 2370,
  protein: 160,
  carbs: 240,
  fat: 65
}

const DEFAULT_MEAL_NAMES = ['Breakfast', 'Lunch', 'Dinner', 'Snacks']

interface StoredEntryRecord {
  id: string
  mealId: string
  date: string
  entry: MealEntry
}

class OfflineMacroStorageService {
  private async getStoredEntries(): Promise<StoredEntryRecord[]> {
    try {
      const db = await getDatabase()
      const rows = await db.getAllAsync<{data: string}>('SELECT data FROM meals ORDER BY createdAt ASC')
      if (rows && rows.length > 0) {
        return rows.map(r => (typeof r.data === 'string' ? JSON.parse(r.data) : (r as any)))
      }
    } catch (e) {
      console.warn('[SQLite] Fallback to AsyncStorage for meals:', e)
    }

    try {
      const saved = await AsyncStorage.getItem('kf_offline_meals')
      return saved ? JSON.parse(saved) : []
    } catch {
      return []
    }
  }

  private async saveStoredEntries(entries: StoredEntryRecord[]): Promise<void> {
    try {
      await AsyncStorage.setItem('kf_offline_meals', JSON.stringify(entries)).catch(() => {})
    } catch {}
  }

  async getTargets(): Promise<MacroTargets> {
    try {
      const saved = await AsyncStorage.getItem(MACRO_TARGETS_KEY)
      if (saved) {
        return JSON.parse(saved)
      }
    } catch {}
    return DEFAULT_TARGETS
  }

  async setTargets(targets: Partial<MacroTargets>): Promise<MacroTargets> {
    const current = await this.getTargets()
    const updated = {...current, ...targets}
    await AsyncStorage.setItem(MACRO_TARGETS_KEY, JSON.stringify(updated)).catch(() => {})
    return updated
  }

  async getDailyMacros(date: string): Promise<DailyMacros> {
    const dateIso = date.split('T')[0]
    const allEntries = await this.getStoredEntries()
    const dayEntries = allEntries.filter(e => e.date === dateIso)
    const targets = await this.getTargets()

    const meals: Meal[] = DEFAULT_MEAL_NAMES.map((name, index) => {
      const mealId = `meal-${name.toLowerCase()}-${dateIso}`
      const entriesForMeal = dayEntries.filter(e => e.mealId === mealId || e.mealId === `meal-${name.toLowerCase()}`)
      const entries = entriesForMeal.map(e => e.entry)

      const totals: MacroTotals = entries.reduce(
        (acc, entry) => {
          const mult = entry.servings || 1
          acc.calories += Math.round(entry.calories * mult)
          acc.protein += Math.round(entry.protein * mult)
          acc.carbs += Math.round(entry.carbs * mult)
          acc.fat += Math.round(entry.fat * mult)
          return acc
        },
        {calories: 0, protein: 0, carbs: 0, fat: 0}
      )

      return {
        id: mealId,
        name,
        sortOrder: index + 1,
        entries,
        totals
      }
    })

    const totals: MacroTotals = meals.reduce(
      (acc, meal) => {
        acc.calories += meal.totals.calories
        acc.protein += meal.totals.protein
        acc.carbs += meal.totals.carbs
        acc.fat += meal.totals.fat
        return acc
      },
      createEmptyMacroTotals()
    )

    return {
      date: dateIso,
      meals,
      totals,
      targets
    }
  }

  async logMealEntry(mealId: string, payload: LogMealEntryPayload): Promise<MealEntry> {
    const allEntries = await this.getStoredEntries()
    const entryId = `entry-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`
    
    // Extract date from mealId if formatted as `meal-xxx-YYYY-MM-DD`, otherwise use today
    const match = mealId.match(/(\d{4}-\d{2}-\d{2})/)
    const date = match ? match[1] : new Date().toISOString().split('T')[0]

    const newEntry: MealEntry = {
      id: entryId,
      foodId: payload.foodId ?? null,
      name: payload.name,
      servingText: payload.servingText ?? '1 serving',
      servings: payload.servings ?? 1,
      calories: payload.calories,
      protein: payload.protein,
      carbs: payload.carbs,
      fat: payload.fat,
      inputMethod: payload.inputMethod ?? InputMethodEnum.LIBRARY,
      loggedAt: new Date().toISOString()
    }

    const record: StoredEntryRecord = {
      id: entryId,
      mealId,
      date,
      entry: newEntry
    }

    allEntries.push(record)
    await this.saveStoredEntries(allEntries)

    try {
      const db = await getDatabase()
      await db.runAsync(
        'INSERT OR REPLACE INTO meals (id, date, name, calories, protein, carbs, fat, data, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        entryId,
        date,
        newEntry.name,
        newEntry.calories,
        newEntry.protein,
        newEntry.carbs,
        newEntry.fat,
        JSON.stringify(record),
        Date.now()
      )
    } catch (e) {
      console.warn('[SQLite] Meal SQLite save fallback:', e)
    }

    return newEntry
  }

  async deleteMealEntry(entryId: string): Promise<void> {
    const allEntries = await this.getStoredEntries()
    const remaining = allEntries.filter(e => e.id !== entryId && e.entry.id !== entryId)
    await this.saveStoredEntries(remaining)

    try {
      const db = await getDatabase()
      await db.runAsync('DELETE FROM meals WHERE id = ?', entryId)
    } catch (e) {
      console.warn('[SQLite] Meal SQLite delete fallback:', e)
    }
  }

  async updateMealEntry(entryId: string, payload: UpdateMealEntryPayload): Promise<MealEntry> {
    const allEntries = await this.getStoredEntries()
    const target = allEntries.find(e => e.id === entryId || e.entry.id === entryId)

    if (!target) {
      throw new Error(`Meal entry ${entryId} not found`)
    }

    target.entry = {
      ...target.entry,
      ...(payload.name !== undefined && {name: payload.name}),
      ...(payload.servings !== undefined && {servings: payload.servings}),
      ...(payload.calories !== undefined && {calories: payload.calories}),
      ...(payload.protein !== undefined && {protein: payload.protein}),
      ...(payload.carbs !== undefined && {carbs: payload.carbs}),
      ...(payload.fat !== undefined && {fat: payload.fat})
    }

    await this.saveStoredEntries(allEntries)

    try {
      const db = await getDatabase()
      await db.runAsync(
        'INSERT OR REPLACE INTO meals (id, date, name, calories, protein, carbs, fat, data, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        entryId,
        target.date,
        target.entry.name,
        target.entry.calories,
        target.entry.protein,
        target.entry.carbs,
        target.entry.fat,
        JSON.stringify(target),
        Date.now()
      )
    } catch (e) {}

    return target.entry
  }

  async getHistory(): Promise<DailySummary[]> {
    const allEntries = await this.getStoredEntries()
    const groupedByDate: Record<string, StoredEntryRecord[]> = {}

    for (const record of allEntries) {
      if (!groupedByDate[record.date]) {
        groupedByDate[record.date] = []
      }
      groupedByDate[record.date].push(record)
    }

    const dates = Object.keys(groupedByDate).sort((a, b) => b.localeCompare(a))

    return dates.map(date => {
      const records = groupedByDate[date]
      const totals = records.reduce(
        (acc, r) => {
          const mult = r.entry.servings || 1
          acc.calories += Math.round(r.entry.calories * mult)
          acc.protein += Math.round(r.entry.protein * mult)
          acc.carbs += Math.round(r.entry.carbs * mult)
          acc.fat += Math.round(r.entry.fat * mult)
          return acc
        },
        {calories: 0, protein: 0, carbs: 0, fat: 0}
      )

      return {
        date,
        mealCount: records.length,
        calories: totals.calories,
        protein: totals.protein,
        carbs: totals.carbs,
        fat: totals.fat
      }
    })
  }
}

const offlineMacroStorageService = new OfflineMacroStorageService()
export default offlineMacroStorageService
