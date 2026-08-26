import {Food} from '@data/models/Food'
import {convertFood} from '@queries/api/macros/converter/convertFood'
import {FoodResponse, PaginationResponse} from '@queries/api/macros/decoder/MacrosDecoder'
import {httpGet} from '@service/http/httpUtil'
import offlineFoodStorageService from '@service/foods/OfflineFoodStorageService'
import CrashUtility from '@utility/CrashUtility'
import * as io from 'io-ts'

import Endpoints from '@constants/endpoints'

const FoodsResponse = io.type({
  foods: io.array(FoodResponse),
  pagination: PaginationResponse
})

export interface FoodsPage {
  foods: Food[]
  pagination: io.TypeOf<typeof PaginationResponse>
}

export async function fetchFoods(query: string, page: number, limit: number = 25): Promise<FoodsPage> {
  try {
    const url = `${Endpoints.Foods}?q=${encodeURIComponent(query)}&page=${page}&limit=${limit}`
    const response = await httpGet(url, FoodsResponse)

    if (response?.status === 200 && response.data) {
      return {
        foods: response.data.foods.map(convertFood),
        pagination: response.data.pagination
      }
    }
  } catch (error) {
    CrashUtility.recordError(error)
  }

  // Fallback to local offline food storage
  const {foods, total} = await offlineFoodStorageService.searchFoods(query, page, limit)
  return {
    foods,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit) || 1
    }
  }
}
