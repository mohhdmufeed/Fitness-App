import {WorkoutDay} from '@data/models/WorkoutDay'
import {compareIsoDateStrings} from '@utility/DateUtility'
import * as FileSystem from 'expo-file-system/legacy'
import getDatabase from '@service/database/sqliteDatabase'

const OFFLINE_FILE_PATH = `${FileSystem.documentDirectory}unsynced-workouts.json`
const TEMP_FILE_PATH = `${FileSystem.documentDirectory}unsynced-workouts.tmp.json`

class OfflineWorkoutStorageService {
  // Serializes writes instead of dropping them — a skipped write here means a
  // silently lost workout mutation when two callers race.
  private writeQueue: Promise<unknown> = Promise.resolve()

  private withLock(task: () => Promise<void>): Promise<void> {
    const result = this.writeQueue.then(task)

    this.writeQueue = result.catch(() => undefined)

    return result
  }

  async readAll(): Promise<WorkoutDay[]> {
    try {
      const fileInfo = await FileSystem.getInfoAsync(OFFLINE_FILE_PATH)

      if (fileInfo.exists) {
        const content = await FileSystem.readAsStringAsync(OFFLINE_FILE_PATH)
        return JSON.parse(content || '[]')
      }
    } catch (error) {
      console.error('Failed to read offline workouts:', error)
    }

    try {
      const db = await getDatabase()
      const rows = await db.getAllAsync<{data: string}>('SELECT data FROM workouts ORDER BY updatedAt DESC')
      
      if (rows && rows.length > 0) {
        return rows.map(r => (typeof r.data === 'string' ? JSON.parse(r.data) : (r as any)))
      }
    } catch (e) {
      console.warn('[SQLite] Fallback to file storage for workouts:', e)
    }

    return []
  }

  async save(workoutDay: WorkoutDay): Promise<void> {
    await this.withLock(async () => {
      // 1. Save to SQLite database
      try {
        const db = await getDatabase()
        const json = JSON.stringify(workoutDay)
        await db.runAsync(
          'INSERT OR REPLACE INTO workouts (date, id, userId, data, updatedAt, synced) VALUES (?, ?, ?, ?, ?, ?)',
          workoutDay.date,
          workoutDay.id || '',
          workoutDay.userId || 'offline-user-1',
          json,
          workoutDay.updatedAt || Date.now(),
          workoutDay.synced ? 1 : 0
        )
      } catch (e) {
        console.warn('[SQLite] Save workout fallback:', e)
      }

      // 2. Dual-save to FileSystem for redundancy
      const existing = await this.readAll()
      const updated = existing.filter(w => !compareIsoDateStrings(w.date, workoutDay.date))
      updated.push(workoutDay)

      const json = JSON.stringify(updated)
      await FileSystem.writeAsStringAsync(TEMP_FILE_PATH, json)
      await FileSystem.moveAsync({
        from: TEMP_FILE_PATH,
        to: OFFLINE_FILE_PATH
      })
    })
  }

  async clear(): Promise<void> {
    await this.withLock(async () => {
      try {
        const db = await getDatabase()
        await db.runAsync('DELETE FROM workouts')
      } catch (e) {
        console.warn('[SQLite] Clear workouts error:', e)
      }

      const fileInfo = await FileSystem.getInfoAsync(OFFLINE_FILE_PATH)
      if (fileInfo.exists) {
        await FileSystem.deleteAsync(OFFLINE_FILE_PATH)
      }
    })
  }

  async deleteAllSynced(keepOnOrAfterDate?: string): Promise<void> {
    await this.withLock(async () => {
      try {
        const db = await getDatabase()
        if (keepOnOrAfterDate) {
          await db.runAsync('DELETE FROM workouts WHERE synced = 1 AND date < ?', keepOnOrAfterDate)
        } else {
          await db.runAsync('DELETE FROM workouts WHERE synced = 1')
        }
      } catch (e) {
        console.warn('[SQLite] Delete synced error:', e)
      }

      const allWorkouts = await this.readAll()
      const remaining = allWorkouts.filter(
        w => !w.synced || (!!keepOnOrAfterDate && w.date.split('T')[0] >= keepOnOrAfterDate)
      )

      const json = JSON.stringify(remaining)
      await FileSystem.writeAsStringAsync(TEMP_FILE_PATH, json)
      await FileSystem.moveAsync({
        from: TEMP_FILE_PATH,
        to: OFFLINE_FILE_PATH
      })

      console.log(`Deleted ${allWorkouts.length - remaining.length} synced workout(s).`)
    })
  }

  async deleteByDate(date: string): Promise<void> {
    await this.withLock(async () => {
      try {
        const db = await getDatabase()
        await db.runAsync('DELETE FROM workouts WHERE date = ?', date)
      } catch (e) {
        console.warn('[SQLite] Delete by date error:', e)
      }

      const allWorkouts = await this.readAll()
      const remaining = allWorkouts.filter(w => !compareIsoDateStrings(w.date, date))

      const json = JSON.stringify(remaining)
      await FileSystem.writeAsStringAsync(TEMP_FILE_PATH, json)
      await FileSystem.moveAsync({
        from: TEMP_FILE_PATH,
        to: OFFLINE_FILE_PATH
      })

      console.log(`Deleted workout with date ${date}`)
    })
  }

  async findLocalWorkoutByDate(date: string): Promise<WorkoutDay | null> {
    const workouts = await this.readAll()
    const workout = workouts.find(w => compareIsoDateStrings(w.date, date))
    if (workout) return workout

    try {
      const db = await getDatabase()
      const row = await db.getFirstAsync<{data: string}>('SELECT data FROM workouts WHERE date = ?', date)
      if (row && row.data) {
        return typeof row.data === 'string' ? JSON.parse(row.data) : (row.data as any)
      }
    } catch (e) {
      console.warn('[SQLite] Find workout by date fallback:', e)
    }

    return null
  }
}

const offlineWorkoutStorageService = new OfflineWorkoutStorageService()

export default offlineWorkoutStorageService
