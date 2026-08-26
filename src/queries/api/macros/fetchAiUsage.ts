import {AiUsage} from '@data/models/AiUsage'
import {httpGet} from '@service/http/httpUtil'
import CrashUtility from '@utility/CrashUtility'
import * as io from 'io-ts'

import Endpoints from '@constants/endpoints'

const AiUsageResponse = io.type({
  used: io.number,
  limit: io.number,
  resetsAt: io.string,
  unlimited: io.boolean
})

export async function fetchAiUsage(): Promise<AiUsage> {
  try {
    const response = await httpGet(Endpoints.AiUsage, AiUsageResponse)

    if (response?.status === 200 && response.data) {
      return response.data
    }
  } catch (error) {
    CrashUtility.recordError(error)
  }

  // Unlimited offline AI usage
  return {
    used: 0,
    limit: 1000,
    resetsAt: new Date(Date.now() + 86400000).toISOString(),
    unlimited: true
  }
}
