import {CreateFoodPayload, Food, FoodSourceEnum} from '@data/models/Food'
import AsyncStorage from '@react-native-async-storage/async-storage'
import getDatabase from '@service/database/sqliteDatabase'

const SEED_FOODS: Food[] = [
  {
    id: 'seed-1',
    name: 'Chicken Breast (Cooked)',
    servingAmount: 100,
    servingUnit: 'g',
    calories: 165,
    protein: 31,
    carbs: 0,
    fat: 3.6,
    brand: null,
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-2',
    name: 'Whole Large Egg',
    servingAmount: 1,
    servingUnit: 'large egg',
    calories: 72,
    protein: 6.3,
    carbs: 0.4,
    fat: 4.8,
    brand: null,
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-3',
    name: 'Whey Protein Isolate',
    servingAmount: 1,
    servingUnit: 'scoop (30g)',
    calories: 120,
    protein: 24,
    carbs: 2,
    fat: 1.5,
    brand: 'Optimum Nutrition',
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-4',
    name: 'Greek Yogurt 0% Fat',
    servingAmount: 170,
    servingUnit: 'g',
    calories: 100,
    protein: 17,
    carbs: 6,
    fat: 0,
    brand: 'Chobani',
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-5',
    name: 'Rolled Oats',
    servingAmount: 40,
    servingUnit: 'g (1/2 cup)',
    calories: 150,
    protein: 5,
    carbs: 27,
    fat: 2.5,
    brand: 'Quaker',
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-6',
    name: 'White Jasmine Rice (Cooked)',
    servingAmount: 150,
    servingUnit: 'g (1 cup)',
    calories: 195,
    protein: 4,
    carbs: 42,
    fat: 0.5,
    brand: null,
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-7',
    name: 'Atlantic Salmon Fillet',
    servingAmount: 100,
    servingUnit: 'g',
    calories: 208,
    protein: 22,
    carbs: 0,
    fat: 13,
    brand: null,
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-8',
    name: 'Extra Lean Ground Beef 93/7',
    servingAmount: 100,
    servingUnit: 'g',
    calories: 152,
    protein: 21,
    carbs: 0,
    fat: 7,
    brand: null,
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-9',
    name: 'Natural Peanut Butter',
    servingAmount: 32,
    servingUnit: 'g (2 tbsp)',
    calories: 190,
    protein: 8,
    carbs: 7,
    fat: 16,
    brand: 'Smucker\'s',
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-10',
    name: 'Banana',
    servingAmount: 1,
    servingUnit: 'medium (118g)',
    calories: 105,
    protein: 1.3,
    carbs: 27,
    fat: 0.3,
    brand: null,
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-11',
    name: 'Sourdough Bread',
    servingAmount: 1,
    servingUnit: 'slice (50g)',
    calories: 120,
    protein: 4,
    carbs: 24,
    fat: 0.8,
    brand: null,
    source: FoodSourceEnum.SEED
  },
  {
    id: 'seed-12',
    name: 'Low Fat Cottage Cheese',
    servingAmount: 110,
    servingUnit: 'g (1/2 cup)',
    calories: 90,
    protein: 14,
    carbs: 5,
    fat: 1.5,
    brand: null,
    source: FoodSourceEnum.SEED
  }
]

const CUSTOM_FOODS_STORAGE_KEY = 'kf_custom_foods'

class OfflineFoodStorageService {
  private async getCustomFoods(): Promise<Food[]> {
    try {
      const saved = await AsyncStorage.getItem(CUSTOM_FOODS_STORAGE_KEY)
      return saved ? JSON.parse(saved) : []
    } catch {
      return []
    }
  }

  private async saveCustomFoods(foods: Food[]): Promise<void> {
    try {
      await AsyncStorage.setItem(CUSTOM_FOODS_STORAGE_KEY, JSON.stringify(foods)).catch(() => {})
    } catch {}
  }

  async getAllFoods(): Promise<Food[]> {
    const custom = await this.getCustomFoods()
    return [...custom, ...SEED_FOODS]
  }

  async searchFoods(query: string, page: number = 1, limit: number = 25): Promise<{foods: Food[]; total: number}> {
    const all = await this.getAllFoods()
    const cleanQuery = query.toLowerCase().trim()

    const filtered = cleanQuery
      ? all.filter(f => f.name.toLowerCase().includes(cleanQuery) || (f.brand && f.brand.toLowerCase().includes(cleanQuery)))
      : all

    const start = (page - 1) * limit
    const paged = filtered.slice(start, start + limit)

    return {
      foods: paged,
      total: filtered.length
    }
  }

  async createFood(payload: CreateFoodPayload): Promise<Food> {
    const custom = await this.getCustomFoods()
    const newFood: Food = {
      id: `food-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
      name: payload.name,
      servingAmount: payload.servingAmount ?? 1,
      servingUnit: payload.servingUnit ?? 'serving',
      calories: payload.calories,
      protein: payload.protein,
      carbs: payload.carbs,
      fat: payload.fat,
      brand: payload.brand ?? null,
      source: payload.source ?? FoodSourceEnum.MANUAL
    }

    custom.unshift(newFood)
    await this.saveCustomFoods(custom)

    try {
      const db = await getDatabase()
      await db.runAsync(
        'INSERT OR REPLACE INTO meals (id, date, name, calories, protein, carbs, fat, data, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        newFood.id,
        'custom_food',
        newFood.name,
        newFood.calories,
        newFood.protein,
        newFood.carbs,
        newFood.fat,
        JSON.stringify(newFood),
        Date.now()
      )
    } catch {}

    return newFood
  }

  async deleteFood(foodId: string): Promise<void> {
    const custom = await this.getCustomFoods()
    const remaining = custom.filter(f => f.id !== foodId)
    await this.saveCustomFoods(remaining)
  }
}

const offlineFoodStorageService = new OfflineFoodStorageService()
export default offlineFoodStorageService
