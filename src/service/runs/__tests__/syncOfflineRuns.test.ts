import {RunRecord} from '@data/models/RunRecord'
import {createRun} from '@queries/api/runs/createRun'
import {updateRun} from '@queries/api/runs/updateRun'
import offlineRunStorageService from '@service/runs/OfflineRunStorageService'

import syncOfflineRuns from '../syncOfflineRuns'

jest.mock('@queries/api/runs/createRun', () => ({
  createRun: jest.fn()
}))

jest.mock('@queries/api/runs/updateRun', () => ({
  updateRun: jest.fn()
}))

jest.mock('@service/runs/OfflineRunStorageService', () => ({
  __esModule: true,
  default: {
    readAll: jest.fn(),
    save: jest.fn(),
    deleteAllSynced: jest.fn(),
    deleteByLocalId: jest.fn()
  }
}))

jest.mock('@utility/CrashUtility', () => ({
  __esModule: true,
  default: {recordError: jest.fn()}
}))

jest.mock('@utility/isServerFailureError', () => ({
  isServerFailureError: jest.fn(),
  isPermanentRejectionError: jest.fn()
}))

const mockCreateRun = jest.mocked(createRun)
const mockUpdateRun = jest.mocked(updateRun)
const mockStorage = jest.mocked(offlineRunStorageService)
const mockIsServerFailureError = require('@utility/isServerFailureError').isServerFailureError as jest.Mock
const mockIsPermanentRejectionError = require('@utility/isServerFailureError').isPermanentRejectionError as jest.Mock

const makeRun = (overrides: Partial<RunRecord> = {}): RunRecord => ({
  localId: 'local-1',
  userId: 'user-1',
  startedAt: '2026-06-01T10:00:00.000Z',
  updatedAt: 0,
  durationSeconds: 1800,
  distanceMeters: 3218,
  runType: 'OUTDOOR',
  source: 'GPS',
  synced: false,
  ...overrides
})

describe('syncOfflineRuns', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    mockStorage.save.mockResolvedValue(undefined)
    mockStorage.deleteAllSynced.mockResolvedValue(undefined)
    mockIsServerFailureError.mockReturnValue(false)
    mockIsPermanentRejectionError.mockReturnValue(false)
  })

  it('creates unsynced runs without a remote id and marks them synced', async () => {
    const run = makeRun()

    mockStorage.readAll.mockResolvedValue([run])
    mockCreateRun.mockResolvedValue({run: {...run, id: 'remote-1', synced: true}, newRecords: []})

    await syncOfflineRuns()

    expect(mockCreateRun).toHaveBeenCalledWith(run)
    expect(mockStorage.save).toHaveBeenCalledWith(
      expect.objectContaining({id: 'remote-1', synced: true, syncAttempts: 0})
    )
  })

  it('updates runs that already have a remote id', async () => {
    const run = makeRun({id: 'remote-1'})

    mockStorage.readAll.mockResolvedValue([run])
    mockUpdateRun.mockResolvedValue({run: {...run, synced: true}, newRecords: []})

    await syncOfflineRuns()

    expect(mockUpdateRun).toHaveBeenCalledWith(run)
    expect(mockCreateRun).not.toHaveBeenCalled()
  })

  it('never pushes drafts awaiting the save/discard decision', async () => {
    mockStorage.readAll.mockResolvedValue([makeRun({draft: true})])

    await syncOfflineRuns()

    expect(mockCreateRun).not.toHaveBeenCalled()
    expect(mockUpdateRun).not.toHaveBeenCalled()
  })

  it('skips already-synced runs', async () => {
    mockStorage.readAll.mockResolvedValue([makeRun({synced: true})])

    await syncOfflineRuns()

    expect(mockCreateRun).not.toHaveBeenCalled()
  })

  it('increments the attempt counter on a server failure (5xx) and keeps the run', async () => {
    const run = makeRun({syncAttempts: 1})

    mockStorage.readAll.mockResolvedValue([run])
    mockCreateRun.mockRejectedValue(new Error('server down'))
    mockIsServerFailureError.mockReturnValue(true)

    await syncOfflineRuns()

    expect(mockStorage.save).toHaveBeenCalledWith(expect.objectContaining({localId: 'local-1', syncAttempts: 2}))
    expect(mockStorage.deleteByLocalId).not.toHaveBeenCalled()
  })

  it('aborts the pass on a network/offline error without burning any attempts', async () => {
    const first = makeRun({localId: 'local-1'})
    const second = makeRun({localId: 'local-2'})

    mockStorage.readAll.mockResolvedValue([first, second])
    mockCreateRun.mockRejectedValue(new Error('network request failed'))

    await syncOfflineRuns()

    // One probe request tells us the server is unreachable — the second run
    // is not attempted and neither run's counter moves.
    expect(mockCreateRun).toHaveBeenCalledTimes(1)
    expect(mockStorage.save).not.toHaveBeenCalledWith(expect.objectContaining({syncAttempts: 1}))
    expect(mockStorage.deleteByLocalId).not.toHaveBeenCalled()
  })

  it('parks a run immediately on a permanent rejection (4xx)', async () => {
    const run = makeRun({syncAttempts: 0})

    mockStorage.readAll.mockResolvedValue([run])
    mockCreateRun.mockRejectedValue(new Error('bad request'))
    mockIsPermanentRejectionError.mockReturnValue(true)

    await syncOfflineRuns()

    expect(mockStorage.save).toHaveBeenCalledWith(expect.objectContaining({localId: 'local-1', syncAttempts: 3}))
    expect(mockStorage.deleteByLocalId).not.toHaveBeenCalled()
  })

  it('parks runs that exhausted their attempts instead of deleting them', async () => {
    mockStorage.readAll.mockResolvedValue([makeRun({syncAttempts: 3})])

    await syncOfflineRuns()

    expect(mockCreateRun).not.toHaveBeenCalled()
    expect(mockStorage.deleteByLocalId).not.toHaveBeenCalled()
    expect(mockStorage.save).not.toHaveBeenCalled()
  })

  it('gives parked runs a fresh set of attempts when retryParked is set', async () => {
    const run = makeRun({syncAttempts: 3})

    mockStorage.readAll.mockResolvedValue([run])
    mockCreateRun.mockResolvedValue({run: {...run, id: 'remote-1', synced: true}, newRecords: []})

    await syncOfflineRuns({retryParked: true})

    expect(mockCreateRun).toHaveBeenCalledWith(run)
    expect(mockStorage.save).toHaveBeenCalledWith(expect.objectContaining({synced: true, syncAttempts: 0}))
  })

  it('restarts the attempt counter from zero when a retried parked run fails again', async () => {
    const run = makeRun({syncAttempts: 3})

    mockStorage.readAll.mockResolvedValue([run])
    mockCreateRun.mockRejectedValue(new Error('server down'))
    mockIsServerFailureError.mockReturnValue(true)

    await syncOfflineRuns({retryParked: true})

    expect(mockStorage.save).toHaveBeenCalledWith(expect.objectContaining({localId: 'local-1', syncAttempts: 1}))
  })

  it('resurrects only the newest parked runs per pass, leaving the rest parked', async () => {
    const parked = Array.from({length: 12}, (_, i) =>
      makeRun({
        localId: `local-${i}`,
        startedAt: `2026-06-${String(i + 1).padStart(2, '0')}T10:00:00.000Z`,
        syncAttempts: 3
      })
    )

    mockStorage.readAll.mockResolvedValue(parked)
    mockCreateRun.mockImplementation(async run => ({
      run: {...run, id: `remote-${run.localId}`, synced: true},
      newRecords: []
    }))

    await syncOfflineRuns({retryParked: true})

    // 12 parked, cap is 10 — the two oldest (June 1 and 2) stay parked
    expect(mockCreateRun).toHaveBeenCalledTimes(10)

    const attempted = mockCreateRun.mock.calls.map(([run]) => run.localId)

    expect(attempted).not.toContain('local-0')
    expect(attempted).not.toContain('local-1')
  })

  it('sweeps synced records at the end', async () => {
    mockStorage.readAll.mockResolvedValue([])

    await syncOfflineRuns()

    expect(mockStorage.deleteAllSynced).toHaveBeenCalled()
  })
})
