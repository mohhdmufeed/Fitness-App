import {Platform} from 'react-native'

export interface SQLiteDatabaseInterface {
  execAsync(sql: string): Promise<void>
  runAsync(sql: string, ...params: any[]): Promise<{changes: number; lastInsertRowId: number}>
  getAllAsync<T = any>(sql: string, ...params: any[]): Promise<T[]>
  getFirstAsync<T = any>(sql: string, ...params: any[]): Promise<T | null>
}

let dbInstance: SQLiteDatabaseInterface | null = null

/**
 * In-memory fallback database for environments where native SQLite is unavailable (Web, Jest).
 */
class FallbackDatabase implements SQLiteDatabaseInterface {
  private tables: Record<string, Map<string, any>> = {}

  private getTable(name: string): Map<string, any> {
    if (!this.tables[name]) {
      this.tables[name] = new Map()
    }
    return this.tables[name]
  }

  async execAsync(_sql: string): Promise<void> {
    return Promise.resolve()
  }

  async runAsync(sql: string, ...params: any[]): Promise<{changes: number; lastInsertRowId: number}> {
    const trimmed = sql.trim()
    const upper = trimmed.toUpperCase()

    if (upper.startsWith('INSERT') || upper.startsWith('REPLACE')) {
      const match = trimmed.match(/INTO\s+(\w+)/i)
      const tableName = match ? match[1] : 'default'
      const key = params[0] || String(Date.now())
      this.getTable(tableName).set(String(key), params)
      return {changes: 1, lastInsertRowId: 1}
    }

    if (upper.startsWith('DELETE')) {
      const match = trimmed.match(/FROM\s+(\w+)/i)
      const tableName = match ? match[1] : 'default'
      if (upper.includes('WHERE')) {
        const key = params[0]
        if (key !== undefined) {
          this.getTable(tableName).delete(String(key))
        }
      } else {
        this.getTable(tableName).clear()
      }
      return {changes: 1, lastInsertRowId: 0}
    }

    return {changes: 0, lastInsertRowId: 0}
  }

  async getAllAsync<T = any>(sql: string, ...params: any[]): Promise<T[]> {
    const trimmed = sql.trim()
    const match = trimmed.match(/FROM\s+(\w+)/i)
    const tableName = match ? match[1] : 'default'
    const table = this.getTable(tableName)
    const results: T[] = []

    for (const [, val] of table) {
      if (Array.isArray(val) && val.length > 0) {
        // Find JSON payload if present
        const jsonParam = val.find(p => typeof p === 'string' && (p.startsWith('{') || p.startsWith('[')))
        if (jsonParam) {
          try {
            results.push(JSON.parse(jsonParam) as T)
          } catch {
            results.push(val as any)
          }
        } else {
          results.push(val as any)
        }
      }
    }

    return results
  }

  async getFirstAsync<T = any>(sql: string, ...params: any[]): Promise<T | null> {
    const all = await this.getAllAsync<T>(sql, ...params)
    return all.length > 0 ? all[0] : null
  }
}

/**
 * Initializes and retrieves the singleton SQLite Database instance.
 */
export async function getDatabase(): Promise<SQLiteDatabaseInterface> {
  if (dbInstance) {
    return dbInstance
  }

  // Native SQLite on Android & iOS
  if (Platform.OS === 'android' || Platform.OS === 'ios') {
    try {
      const SQLite = require('expo-sqlite')
      const db = await SQLite.openDatabaseAsync('kinetic_fusion.db')
      
      // Initialize core tables
      await db.execAsync(`
        PRAGMA journal_mode = WAL;
        
        CREATE TABLE IF NOT EXISTS workouts (
          date TEXT PRIMARY KEY,
          id TEXT,
          userId TEXT,
          data TEXT NOT NULL,
          updatedAt INTEGER NOT NULL,
          synced INTEGER DEFAULT 0
        );

        CREATE TABLE IF NOT EXISTS runs (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          data TEXT NOT NULL,
          distance REAL DEFAULT 0,
          duration INTEGER DEFAULT 0,
          calories INTEGER DEFAULT 0,
          pace REAL DEFAULT 0,
          createdAt INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS meals (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          name TEXT NOT NULL,
          calories REAL DEFAULT 0,
          protein REAL DEFAULT 0,
          carbs REAL DEFAULT 0,
          fat REAL DEFAULT 0,
          data TEXT NOT NULL,
          createdAt INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS body_metrics (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          weight REAL NOT NULL,
          unit TEXT NOT NULL,
          data TEXT,
          createdAt INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS custom_exercises (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          category TEXT,
          targetMuscles TEXT,
          data TEXT
        );

        CREATE TABLE IF NOT EXISTS app_cache (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updatedAt INTEGER NOT NULL
        );
      `)

      dbInstance = db
      return db
    } catch (error) {
      console.warn('[SQLite] Failed to open native SQLite database, falling back to storage:', error)
    }
  }

  // Fallback for Web / testing environments
  dbInstance = new FallbackDatabase()
  return dbInstance
}

export default getDatabase
