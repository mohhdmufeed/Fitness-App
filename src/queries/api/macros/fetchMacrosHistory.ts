import {DailySummary} from '@data/models/DailyMacros'
import {PaginationResponse} from '@queries/api/macros/decoder/MacrosDecoder'
import {httpGet} from '@service/http/httpUtil'
import offlineMacroStorageService from '@service/macros/OfflineMacroStorageService'
import CrashUtility from '@utility/CrashUtility'
import * as io from 'io-ts'

import Endpoints from '@constants/endpoints'

const DaySummaryMealResponse = io.type({
  id: io.string,
  name: io.string,
  sortOrder: io.number,
  calories: io.number,
  protein: io.number,
  carbs: io.number,
  fat: io.number
})

const DailySummaryResponse = io.intersection([
  io.type({
    date: io.string,
    mealCount: io.number,
    calories: io.number,
    protein: io.number,
    carbs: io.number,
    fat: io.number
  }),
  // meals is absent when the server predates the per-meal history breakdown
  io.partial({
    meals: io.array(DaySummaryMealResponse)
  })
])

const MacrosHistoryResponse = io.type({
  days: io.array(DailySummaryResponse),
  pagination: PaginationResponse
})

export interface MacrosHistoryPage {
  days: DailySummary[]
  pagination: io.TypeOf<typeof PaginationResponse>
}

export async function fetchMacrosHistory(page: number, limit: number = 30): Promise<MacrosHistoryPage> {
  try {
    const url = `${Endpoints.MacrosHistory}?page=${page}&limit=${limit}`
    const response = await httpGet(url, MacrosHistoryResponse)

    if (response?.status === 200 && response.data) {
      return response.data
    }
  } catch (error) {
    CrashUtility.recordError(error)
  }

  // Fallback to local offline history
  const allDays = await offlineMacroStorageService.getHistory()
  return {
    days: allDays,
    pagination: {
      page,
      limit,
      total: allDays.length,
      totalPages: 1
    }
  }
}
