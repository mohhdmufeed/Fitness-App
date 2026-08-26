import {httpDelete} from '@service/http/httpUtil'
import offlineFoodStorageService from '@service/foods/OfflineFoodStorageService'
import CrashUtility from '@utility/CrashUtility'
import * as io from 'io-ts'

import Endpoints from '@constants/endpoints'

const DeleteResponse = io.type({success: io.boolean})

export async function deleteFood(foodId: string): Promise<void> {
  try {
    const response = await httpDelete(Endpoints.Food(foodId), DeleteResponse)

    if (response?.status === 200) {
      return
    }
  } catch (error) {
    CrashUtility.recordError(error)
  }

  // Fallback to local offline food storage
  await offlineFoodStorageService.deleteFood(foodId)
}
