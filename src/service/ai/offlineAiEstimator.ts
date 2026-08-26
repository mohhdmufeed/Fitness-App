import {EstimateItem, MacroEstimate} from '@data/models/MacroEstimate'
import {MacroTotals} from '@data/models/Macros'

interface FoodNutrition {
  keywords: string[]
  defaultServing: string
  defaultUnitGrams: number
  // Macros per 100g (or per 1 unit if unitBased is true)
  unitBased?: boolean
  calories: number
  protein: number
  carbs: number
  fat: number
}

const NUTRITION_DATABASE: Record<string, FoodNutrition> = {
  egg: {
    keywords: ['egg', 'eggs', 'boiled egg', 'fried egg', 'scrambled egg'],
    defaultServing: '1 large',
    defaultUnitGrams: 50,
    unitBased: true,
    calories: 72,
    protein: 6.3,
    carbs: 0.4,
    fat: 4.8
  },
  egg_white: {
    keywords: ['egg white', 'egg whites'],
    defaultServing: '1 white',
    defaultUnitGrams: 33,
    unitBased: true,
    calories: 17,
    protein: 3.6,
    carbs: 0.2,
    fat: 0.1
  },
  chicken_breast: {
    keywords: ['chicken breast', 'chicken', 'grilled chicken', 'baked chicken'],
    defaultServing: '100g',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 165,
    protein: 31,
    carbs: 0,
    fat: 3.6
  },
  chicken_thigh: {
    keywords: ['chicken thigh', 'chicken thighs'],
    defaultServing: '100g',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 209,
    protein: 26,
    carbs: 0,
    fat: 10.9
  },
  steak_beef: {
    keywords: ['steak', 'beef', 'ground beef', 'mince', 'ribeye', 'sirloin'],
    defaultServing: '100g',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 250,
    protein: 26,
    carbs: 0,
    fat: 15
  },
  salmon: {
    keywords: ['salmon', 'grilled salmon', 'smoked salmon', 'fish'],
    defaultServing: '100g',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 208,
    protein: 22,
    carbs: 0,
    fat: 13
  },
  tuna: {
    keywords: ['tuna', 'canned tuna', 'tuna fish'],
    defaultServing: '100g',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 130,
    protein: 28,
    carbs: 0,
    fat: 1
  },
  rice: {
    keywords: ['rice', 'white rice', 'brown rice', 'jasmine rice', 'basmati rice'],
    defaultServing: '1 cup cooked',
    defaultUnitGrams: 150,
    unitBased: false,
    calories: 130,
    protein: 2.7,
    carbs: 28,
    fat: 0.3
  },
  oats: {
    keywords: ['oats', 'oatmeal', 'porridge', 'rolled oats'],
    defaultServing: '40g',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 389,
    protein: 16.9,
    carbs: 66.3,
    fat: 6.9
  },
  bread: {
    keywords: ['bread', 'toast', 'sourdough', 'whole wheat bread', 'white bread', 'slice of bread'],
    defaultServing: '1 slice',
    defaultUnitGrams: 40,
    unitBased: true,
    calories: 80,
    protein: 3.5,
    carbs: 15,
    fat: 1
  },
  bagel: {
    keywords: ['bagel'],
    defaultServing: '1 bagel',
    defaultUnitGrams: 100,
    unitBased: true,
    calories: 260,
    protein: 10,
    carbs: 50,
    fat: 2
  },
  protein_powder: {
    keywords: ['whey', 'whey protein', 'protein powder', 'protein shake', 'casein', 'plant protein'],
    defaultServing: '1 scoop (30g)',
    defaultUnitGrams: 30,
    unitBased: true,
    calories: 120,
    protein: 24,
    carbs: 3,
    fat: 1.5
  },
  protein_bar: {
    keywords: ['protein bar', 'protein snack'],
    defaultServing: '1 bar (60g)',
    defaultUnitGrams: 60,
    unitBased: true,
    calories: 210,
    protein: 20,
    carbs: 22,
    fat: 7
  },
  milk: {
    keywords: ['milk', 'whole milk', 'skim milk', 'low fat milk'],
    defaultServing: '1 cup (240ml)',
    defaultUnitGrams: 240,
    unitBased: false,
    calories: 50,
    protein: 3.4,
    carbs: 4.8,
    fat: 2
  },
  almond_milk: {
    keywords: ['almond milk', 'oat milk', 'soy milk'],
    defaultServing: '1 cup (240ml)',
    defaultUnitGrams: 240,
    unitBased: false,
    calories: 30,
    protein: 1,
    carbs: 1.5,
    fat: 2.5
  },
  greek_yogurt: {
    keywords: ['greek yogurt', 'yogurt', 'curd'],
    defaultServing: '150g',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 90,
    protein: 15,
    carbs: 5,
    fat: 0.5
  },
  cheese: {
    keywords: ['cheese', 'cheddar', 'mozzarella', 'parmesan', 'cottage cheese'],
    defaultServing: '30g',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 350,
    protein: 25,
    carbs: 2,
    fat: 28
  },
  peanut_butter: {
    keywords: ['peanut butter', 'almond butter', 'pb'],
    defaultServing: '1 tbsp (16g)',
    defaultUnitGrams: 16,
    unitBased: true,
    calories: 95,
    protein: 4,
    carbs: 3.5,
    fat: 8
  },
  butter_oil: {
    keywords: ['butter', 'olive oil', 'oil', 'coconut oil', 'ghee'],
    defaultServing: '1 tbsp (14g)',
    defaultUnitGrams: 14,
    unitBased: true,
    calories: 120,
    protein: 0,
    carbs: 0,
    fat: 14
  },
  avocado: {
    keywords: ['avocado'],
    defaultServing: '1/2 avocado (100g)',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 160,
    protein: 2,
    carbs: 8.5,
    fat: 14.7
  },
  banana: {
    keywords: ['banana', 'bananas'],
    defaultServing: '1 medium (118g)',
    defaultUnitGrams: 118,
    unitBased: true,
    calories: 105,
    protein: 1.3,
    carbs: 27,
    fat: 0.3
  },
  apple: {
    keywords: ['apple', 'apples'],
    defaultServing: '1 medium (180g)',
    defaultUnitGrams: 180,
    unitBased: true,
    calories: 95,
    protein: 0.5,
    carbs: 25,
    fat: 0.3
  },
  berries: {
    keywords: ['berries', 'blueberries', 'strawberries', 'raspberries'],
    defaultServing: '1 cup (150g)',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 57,
    protein: 0.7,
    carbs: 14,
    fat: 0.3
  },
  potato: {
    keywords: ['potato', 'potatoes', 'sweet potato', 'baked potato'],
    defaultServing: '1 medium (150g)',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 86,
    protein: 1.6,
    carbs: 20,
    fat: 0.1
  },
  pasta: {
    keywords: ['pasta', 'spaghetti', 'noodles', 'macaroni'],
    defaultServing: '1 cup cooked (140g)',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 158,
    protein: 5.8,
    carbs: 31,
    fat: 0.9
  },
  pizza: {
    keywords: ['pizza', 'slice of pizza'],
    defaultServing: '1 slice (107g)',
    defaultUnitGrams: 107,
    unitBased: true,
    calories: 285,
    protein: 12,
    carbs: 36,
    fat: 10
  },
  burger: {
    keywords: ['burger', 'cheeseburger', 'hamburger'],
    defaultServing: '1 burger',
    defaultUnitGrams: 200,
    unitBased: true,
    calories: 450,
    protein: 28,
    carbs: 38,
    fat: 20
  },
  salad: {
    keywords: ['salad', 'green salad', 'broccoli', 'spinach', 'vegetables', 'veggies'],
    defaultServing: '1 bowl (100g)',
    defaultUnitGrams: 100,
    unitBased: false,
    calories: 35,
    protein: 2.5,
    carbs: 6,
    fat: 0.4
  }
}

export class OfflineAiEstimator {
  estimateFromText(text: string): MacroEstimate {
    if (!text || text.trim().length === 0) {
      return {
        items: [],
        total: {calories: 0, protein: 0, carbs: 0, fat: 0},
        confidence: 'low',
        notes: 'No text provided'
      }
    }

    // Split text into clauses/items by commas, "and", "plus", "+", "&", or newlines
    const rawClauses = text
      .split(/,|\band\b|\bplus\b|\+|\&|\n/i)
      .map(s => s.trim())
      .filter(s => s.length > 0)

    const items: EstimateItem[] = []

    for (const clause of rawClauses) {
      const item = this.parseClause(clause)
      if (item) {
        items.push(item)
      }
    }

    // If nothing matched specifically, provide intelligent default item
    if (items.length === 0) {
      items.push({
        name: text.trim().substring(0, 40),
        quantityText: '1 serving',
        calories: 350,
        protein: 20,
        carbs: 40,
        fat: 12
      })
    }

    const total: MacroTotals = items.reduce(
      (acc, item) => ({
        calories: acc.calories + item.calories,
        protein: acc.protein + item.protein,
        carbs: acc.carbs + item.carbs,
        fat: acc.fat + item.fat
      }),
      {calories: 0, protein: 0, carbs: 0, fat: 0}
    )

    return {
      items,
      total,
      confidence: items.length > 0 ? 'high' : 'medium',
      notes: 'Estimated offline with on-device nutrition intelligence'
    }
  }

  private parseClause(clause: string): EstimateItem | null {
    const lower = clause.toLowerCase()

    // Match numbers and units e.g. "2", "200g", "1.5 cups", "3 slices", "1 scoop"
    let multiplier = 1
    let quantityText = '1 serving'

    const gramMatch = lower.match(/(\d+(?:\.\d+)?)\s*(?:g|grams?)\b/)
    const cupMatch = lower.match(/(\d+(?:\.\d+)?)\s*(?:cups?|bowl|bowls?)\b/)
    const sliceMatch = lower.match(/(\d+(?:\.\d+)?)\s*(?:slices?|pieces?|scoops?)\b/)
    const numberMatch = lower.match(/^(\d+(?:\.\d+)?)\s+/)

    let grams = 0

    if (gramMatch) {
      grams = parseFloat(gramMatch[1])
      quantityText = `${grams}g`
    } else if (cupMatch) {
      multiplier = parseFloat(cupMatch[1])
      quantityText = `${multiplier} cup`
    } else if (sliceMatch) {
      multiplier = parseFloat(sliceMatch[1])
      quantityText = `${multiplier} ${sliceMatch[0]}`
    } else if (numberMatch) {
      multiplier = parseFloat(numberMatch[1])
      quantityText = `${multiplier} item`
    }

    // Find best match in database
    let bestFoodKey: string | null = null
    let bestKeyword = ''

    for (const [key, food] of Object.entries(NUTRITION_DATABASE)) {
      for (const kw of food.keywords) {
        if (lower.includes(kw)) {
          if (!bestKeyword || kw.length > bestKeyword.length) {
            bestFoodKey = key
            bestKeyword = kw
          }
        }
      }
    }

    if (!bestFoodKey) {
      // Generic fallback for unmatched words
      const words = clause.replace(/^\d+\s*/, '').trim()
      if (!words) return null

      return {
        name: words.charAt(0).toUpperCase() + words.slice(1),
        quantityText,
        calories: Math.round(250 * multiplier),
        protein: Math.round(15 * multiplier),
        carbs: Math.round(25 * multiplier),
        fat: Math.round(8 * multiplier)
      }
    }

    const food = NUTRITION_DATABASE[bestFoodKey]
    let factor = 1

    if (grams > 0) {
      factor = grams / 100
    } else if (food.unitBased) {
      factor = multiplier
    } else {
      factor = (food.defaultUnitGrams / 100) * multiplier
    }

    const name = clause
      .replace(/^\d+(?:\.\d+)?\s*(?:g|grams?|cups?|slices?|scoops?|pieces?|items?)?\s*(?:of)?\s*/i, '')
      .trim()

    const displayName = name ? name.charAt(0).toUpperCase() + name.slice(1) : bestKeyword

    return {
      name: displayName,
      quantityText: quantityText !== '1 serving' ? quantityText : food.defaultServing,
      calories: Math.round(food.calories * factor),
      protein: Math.round(food.protein * factor),
      carbs: Math.round(food.carbs * factor),
      fat: Math.round(food.fat * factor)
    }
  }
}

const offlineAiEstimator = new OfflineAiEstimator()
export default offlineAiEstimator
