import {MealEntry, UpdateMealEntryPayload} from '@data/models/MealEntry'
import {convertMealEntry} from '@queries/api/macros/converter/convertDailyMacros'
import {MealEntryResponse} from '@queries/api/macros/decoder/MacrosDecoder'
import {httpPut} from '@service/http/httpUtil'
import offlineMacroStorageService from '@service/macros/OfflineMacroStorageService'
import CrashUtility from '@utility/CrashUtility'

import Endpoints from '@constants/endpoints'

export async function updateMealEntry(entryId: string, payload: UpdateMealEntryPayload): Promise<MealEntry> {
  try {
    const response = await httpPut(Endpoints.MacroEntry(entryId), MealEntryResponse, payload)

    if (response?.status === 200 && response.data) {
      return convertMealEntry(response.data)
    }
  } catch (error) {
    CrashUtility.recordError(error)
  }

  // Fallback to local offline storage
  return offlineMacroStorageService.updateMealEntry(entryId, payload)
}
