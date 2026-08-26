import {EstimateMacrosPayload, MacroEstimate} from '@data/models/MacroEstimate'
import {MacroTotalsResponse} from '@queries/api/macros/decoder/MacrosDecoder'
import {httpPost} from '@service/http/httpUtil'
import offlineAiEstimator from '@service/ai/offlineAiEstimator'
import CrashUtility from '@utility/CrashUtility'
import * as io from 'io-ts'

import Endpoints from '@constants/endpoints'

const EstimateItemResponse = io.type({
  name: io.string,
  quantityText: io.string,
  calories: io.number,
  protein: io.number,
  carbs: io.number,
  fat: io.number
})

const EstimateResponse = io.type({
  items: io.array(EstimateItemResponse),
  total: MacroTotalsResponse,
  confidence: io.union([io.literal('low'), io.literal('medium'), io.literal('high')]),
  notes: io.union([io.string, io.null])
})

export async function estimateMacros(payload: EstimateMacrosPayload): Promise<MacroEstimate> {
  try {
    const response = await httpPost(Endpoints.MacroEstimate, EstimateResponse, payload)

    if (response?.status === 200 && response.data) {
      return response.data
    }
  } catch (error) {
    CrashUtility.recordError(error)
  }

  // Use on-device offline AI food & macro estimator
  return offlineAiEstimator.estimateFromText(payload.text || '')
}
