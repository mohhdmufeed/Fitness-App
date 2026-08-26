import {RunRecord} from '@data/models/RunRecord'
import * as FileSystem from 'expo-file-system/legacy'
import getDatabase from '@service/database/sqliteDatabase'

// Atomic file-per-domain offline queue for runs, mirroring
// OfflineWorkoutStorageService exactly, but keyed by `localId` (the runId
// from RunSessionService.start()) instead of by calendar date — runs aren't
// scoped to "today" the way a WorkoutDay is.
const OFFLINE_FILE_PATH = `${FileSystem.documentDirectory}unsynced-runs.json`
const TEMP_FILE_PATH = `${FileSystem.documentDirectory}unsynced-runs.tmp.json`

class OfflineRunStorageService {
  // Serializes writes instead of dropping them — a skipped write here means a
  // silently lost run (e.g. a recovery save racing a background sync).
  private writeQueue: Promise<unknown> = Promise.resolve()

  private withLock(task: () => Promise<void>): Promise<void> {
    const result = this.writeQueue.then(task)

    this.writeQueue = result.catch(() => undefined)

    return result
  }

  async readAll(): Promise<RunRecord[]> {
    try {
      const fileInfo = await FileSystem.getInfoAsync(OFFLINE_FILE_PATH)

      if (fileInfo.exists) {
        const content = await FileSystem.readAsStringAsync(OFFLINE_FILE_PATH)
        return JSON.parse(content || '[]')
      }
    } catch (error) {
      console.error('Failed to read offline runs:', error)
    }

    try {
      const db = await getDatabase()
      const rows = await db.getAllAsync<{data: string}>('SELECT data FROM runs ORDER BY createdAt DESC')
      if (rows && rows.length > 0) {
        return rows.map(r => (typeof r.data === 'string' ? JSON.parse(r.data) : (r as any)))
      }
    } catch (e) {
      console.warn('[SQLite] Fallback to file storage for runs:', e)
    }

    return []
  }

  async save(run: RunRecord): Promise<void> {
    await this.withLock(async () => {
      // 1. Save to SQLite database
      try {
        const db = await getDatabase()
        const json = JSON.stringify(run)
        await db.runAsync(
          'INSERT OR REPLACE INTO runs (id, date, data, distance, duration, calories, pace, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          run.localId,
          run.startedAt || new Date().toISOString(),
          json,
          run.distanceMeters || 0,
          run.durationSeconds || 0,
          run.calories || 0,
          run.avgPaceSecPerKm || 0,
          Date.now()
        )
      } catch (e) {
        console.warn('[SQLite] Save run error:', e)
      }

      // 2. Dual-save to FileSystem for redundancy
      const existing = await this.readAll()
      const updated = existing.filter(r => r.localId !== run.localId)
      updated.push(run)

      const json = JSON.stringify(updated)
      await FileSystem.writeAsStringAsync(TEMP_FILE_PATH, json)
      await FileSystem.moveAsync({
        from: TEMP_FILE_PATH,
        to: OFFLINE_FILE_PATH
      })
    })
  }

  async clear(): Promise<void> {
    await this.withLock(async () => {
      try {
        const db = await getDatabase()
        await db.runAsync('DELETE FROM runs')
      } catch (e) {
        console.warn('[SQLite] Clear runs error:', e)
      }

      const fileInfo = await FileSystem.getInfoAsync(OFFLINE_FILE_PATH)
      if (fileInfo.exists) {
        await FileSystem.deleteAsync(OFFLINE_FILE_PATH)
      }
    })
  }

  async deleteAllSynced(): Promise<void> {
    await this.withLock(async () => {
      const allRuns = await this.readAll()
      const unsyncedOnly = allRuns.filter(r => !r.synced)

      const json = JSON.stringify(unsyncedOnly)
      await FileSystem.writeAsStringAsync(TEMP_FILE_PATH, json)
      await FileSystem.moveAsync({
        from: TEMP_FILE_PATH,
        to: OFFLINE_FILE_PATH
      })
    })
  }

  async deleteByLocalId(localId: string): Promise<void> {
    await this.withLock(async () => {
      try {
        const db = await getDatabase()
        await db.runAsync('DELETE FROM runs WHERE id = ?', localId)
      } catch (e) {
        console.warn('[SQLite] Delete run error:', e)
      }

      const allRuns = await this.readAll()
      const remaining = allRuns.filter(r => r.localId !== localId)

      const json = JSON.stringify(remaining)
      await FileSystem.writeAsStringAsync(TEMP_FILE_PATH, json)
      await FileSystem.moveAsync({
        from: TEMP_FILE_PATH,
        to: OFFLINE_FILE_PATH
      })
    })
  }

  async findLocalRunByLocalId(localId: string): Promise<RunRecord | null> {
    const runs = await this.readAll()
    const run = runs.find(r => r.localId === localId)
    if (run) return run

    try {
      const db = await getDatabase()
      const row = await db.getFirstAsync<{data: string}>('SELECT data FROM runs WHERE id = ?', localId)
      if (row && row.data) {
        return typeof row.data === 'string' ? JSON.parse(row.data) : (row.data as any)
      }
    } catch (e) {
      console.warn('[SQLite] Find run fallback:', e)
    }

    return null
  }
}

const offlineRunStorageService = new OfflineRunStorageService()

export default offlineRunStorageService
