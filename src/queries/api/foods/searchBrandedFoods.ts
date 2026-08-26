import {BrandedFood} from '@data/models/BrandedFood'
import {httpGet} from '@service/http/httpUtil'
import offlineFoodStorageService from '@service/foods/OfflineFoodStorageService'
import CrashUtility from '@utility/CrashUtility'
import * as io from 'io-ts'

import Endpoints from '@constants/endpoints'

const optionalString = io.union([io.string, io.null, io.undefined])

const BrandedFoodResponse = io.type({
  id: io.string,
  name: io.string,
  brand: optionalString,
  servingText: optionalString,
  calories: io.number,
  protein: io.number,
  carbs: io.number,
  fat: io.number
})

const BrandedFoodSearchResponse = io.type({items: io.array(BrandedFoodResponse)})

export async function searchBrandedFoods(query: string): Promise<BrandedFood[]> {
  try {
    const response = await httpGet(Endpoints.BrandedFoodSearch(query), BrandedFoodSearchResponse)

    if (response?.status === 200 && response.data) {
      return response.data.items.map(item => ({
        id: item.id,
        name: item.name,
        brand: item.brand ?? null,
        servingText: item.servingText ?? null,
        calories: item.calories,
        protein: item.protein,
        carbs: item.carbs,
        fat: item.fat
      }))
    }
  } catch (error) {
    CrashUtility.recordError(error)
  }

  // Offline branded food search fallback
  const {foods} = await offlineFoodStorageService.searchFoods(query, 1, 20)
  return foods.map(item => ({
    id: item.id,
    name: item.name,
    brand: item.brand ?? null,
    servingText: item.servingUnit ? `${item.servingAmount} ${item.servingUnit}` : null,
    calories: item.calories,
    protein: item.protein,
    carbs: item.carbs,
    fat: item.fat
  }))
}
