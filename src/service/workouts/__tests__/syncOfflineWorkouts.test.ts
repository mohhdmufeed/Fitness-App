import {saveWorkoutDay} from '@queries/api/workouts/saveWorkoutDay'
import {updateWorkoutDay} from '@queries/api/workouts/updateWorkoutDay'
import offlineWorkoutStorageService from '@service/workouts/OfflineWorkoutStorageService'
import syncOfflineWorkouts from '@service/workouts/syncOfflineWorkouts'

jest.mock('@service/workouts/OfflineWorkoutStorageService', () => ({
  readAll: jest.fn(),
  save: jest.fn(),
  deleteByDate: jest.fn(),
  deleteAllSynced: jest.fn(),
  findLocalWorkoutByDate: jest.fn()
}))

jest.mock('@queries/api/workouts/saveWorkoutDay', () => ({
  saveWorkoutDay: jest.fn()
}))

jest.mock('@queries/api/workouts/updateWorkoutDay', () => ({
  updateWorkoutDay: jest.fn()
}))

jest.mock('@utility/CrashUtility', () => ({
  recordError: jest.fn()
}))

jest.mock('@utility/isServerFailureError', () => ({
  isServerFailureError: jest.fn(),
  isPermanentRejectionError: jest.fn()
}))

const mockReadAll = offlineWorkoutStorageService.readAll as jest.Mock
const mockSave = offlineWorkoutStorageService.save as jest.Mock
const mockDeleteByDate = offlineWorkoutStorageService.deleteByDate as jest.Mock
const mockDeleteAllSynced = offlineWorkoutStorageService.deleteAllSynced as jest.Mock
const mockFindLocalWorkoutByDate = offlineWorkoutStorageService.findLocalWorkoutByDate as jest.Mock
const mockSaveWorkoutDay = saveWorkoutDay as jest.Mock
const mockUpdateWorkoutDay = updateWorkoutDay as jest.Mock
const mockIsServerFailureError = require('@utility/isServerFailureError').isServerFailureError as jest.Mock
const mockIsPermanentRejectionError = require('@utility/isServerFailureError').isPermanentRejectionError as jest.Mock

const TODAY_ISO = '2025-10-20'

beforeEach(() => {
  jest.clearAllMocks()
  mockIsPermanentRejectionError.mockReturnValue(false)
  mockFindLocalWorkoutByDate.mockResolvedValue(null)
})

describe('syncOfflineWorkouts', () => {
  test('skips workout with date equal to today', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-20T00:00:00Z', synced: false}])

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockSaveWorkoutDay).not.toHaveBeenCalled()
    expect(mockSave).not.toHaveBeenCalled()
  })

  test('skips workout already synced', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-19', synced: true}])

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockSaveWorkoutDay).not.toHaveBeenCalled()
    expect(mockSave).not.toHaveBeenCalled()
  })

  test('saves unsynced workout successfully', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-19', synced: false}])
    mockSaveWorkoutDay.mockResolvedValue({id: 'server-id', date: '2025-10-19'})

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockSaveWorkoutDay).toHaveBeenCalled()
    expect(mockSave).toHaveBeenCalledWith(
      expect.objectContaining({
        synced: true,
        syncAttempts: 0
      })
    )
  })

  test('keeps the server-assigned id when marking an id-less workout synced', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-19', synced: false}])
    mockSaveWorkoutDay.mockResolvedValue({id: 'server-id', date: '2025-10-19'})

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockSave).toHaveBeenCalledWith(
      expect.objectContaining({
        id: 'server-id',
        synced: true,
        syncAttempts: 0
      })
    )
  })

  test('merges sync fields into the currently stored workout instead of the stale snapshot', async () => {
    const snapshot = {date: '2025-10-19', synced: false, dailyExercises: []}
    const editedWhileSyncing = {
      date: '2025-10-19',
      synced: false,
      dailyExercises: [{id: 'new-exercise'}],
      updatedAt: 123
    }

    mockReadAll.mockResolvedValue([snapshot])
    mockSaveWorkoutDay.mockResolvedValue({id: 'server-id', date: '2025-10-19'})
    mockFindLocalWorkoutByDate.mockResolvedValue(editedWhileSyncing)

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockFindLocalWorkoutByDate).toHaveBeenCalledWith('2025-10-19')
    expect(mockSave).toHaveBeenCalledWith({
      ...editedWhileSyncing,
      id: 'server-id',
      synced: true,
      syncAttempts: 0
    })
  })

  test('increments syncAttempts on failure < 3', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-19', synced: false, syncAttempts: 1}])
    mockSaveWorkoutDay.mockRejectedValue(new Error('fail'))
    mockIsServerFailureError.mockReturnValue(true)

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockSave).toHaveBeenCalledWith(
      expect.objectContaining({
        syncAttempts: 2
      })
    )
    expect(mockDeleteByDate).not.toHaveBeenCalled()
  })

  test('parks (skips) a workout that already failed 3 times instead of deleting it', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-19', synced: false, syncAttempts: 3}])

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockSaveWorkoutDay).not.toHaveBeenCalled()
    expect(mockUpdateWorkoutDay).not.toHaveBeenCalled()
    expect(mockSave).not.toHaveBeenCalled()
    expect(mockDeleteByDate).not.toHaveBeenCalled()
  })

  test('keeps the workout on the third failed attempt', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-19', synced: false, syncAttempts: 2}])
    mockSaveWorkoutDay.mockRejectedValue(new Error('fail'))
    mockIsServerFailureError.mockReturnValue(true)

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockDeleteByDate).not.toHaveBeenCalled()
    expect(mockSave).toHaveBeenCalledWith(
      expect.objectContaining({
        syncAttempts: 3
      })
    )
  })

  test('parks a workout immediately on a permanent (4xx) rejection', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-19', synced: false}])
    mockSaveWorkoutDay.mockRejectedValue(new Error('bad request'))
    mockIsPermanentRejectionError.mockReturnValue(true)

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockDeleteByDate).not.toHaveBeenCalled()
    expect(mockSave).toHaveBeenCalledWith(
      expect.objectContaining({
        syncAttempts: 3
      })
    )
  })

  test('skips increment if error is not server failure', async () => {
    mockReadAll.mockResolvedValue([{date: '2025-10-19', synced: false, syncAttempts: 1}])
    mockSaveWorkoutDay.mockRejectedValue(new Error('offline'))
    mockIsServerFailureError.mockReturnValue(false)

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockSave).not.toHaveBeenCalled()
    expect(mockDeleteByDate).not.toHaveBeenCalled()
  })

  test('handles malformed date gracefully', async () => {
    mockReadAll.mockResolvedValue([{date: 'not-a-date', synced: false}])
    mockSaveWorkoutDay.mockResolvedValue({id: 'server-id', date: 'not-a-date'})

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockSaveWorkoutDay).toHaveBeenCalled()
    expect(mockSave).toHaveBeenCalledWith(
      expect.objectContaining({
        synced: true,
        syncAttempts: 0
      })
    )
  })

  test('calls updateWorkoutDay if workout has an id', async () => {
    mockReadAll.mockResolvedValue([{id: 'abc123', date: '2025-10-19', synced: false}])
    mockUpdateWorkoutDay.mockResolvedValue({id: 'abc123', date: '2025-10-19'})

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockUpdateWorkoutDay).toHaveBeenCalledWith(expect.objectContaining({id: 'abc123'}))
    expect(mockUpdateWorkoutDay).toHaveBeenCalled()
    expect(mockSaveWorkoutDay).not.toHaveBeenCalled()
    expect(mockSave).toHaveBeenCalledWith(
      expect.objectContaining({
        id: 'abc123',
        synced: true,
        syncAttempts: 0
      })
    )
  })

  test('calls saveWorkoutDay if workout does not have an id', async () => {
    mockReadAll.mockResolvedValue([{id: null, date: '2025-10-19', synced: false}])
    mockSaveWorkoutDay.mockResolvedValue({id: 'server-id', date: '2025-10-19'})

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockUpdateWorkoutDay).not.toHaveBeenCalled()
    expect(mockSaveWorkoutDay).toHaveBeenCalledWith(expect.objectContaining({id: null}))
    expect(mockSave).toHaveBeenCalledWith(
      expect.objectContaining({
        id: 'server-id',
        synced: true,
        syncAttempts: 0
      })
    )
  })

  test('calls deleteAllSynced at the end, keeping days from yesterday onward', async () => {
    mockReadAll.mockResolvedValue([])

    await syncOfflineWorkouts(TODAY_ISO)

    expect(mockDeleteAllSynced).toHaveBeenCalledWith('2025-10-19')
  })
})
