import AsyncStorage from '@react-native-async-storage/async-storage'
import {queryClient} from '@queries/queryClient'
import {FirebaseAuthTypes} from '@react-native-firebase/auth'
import authService from '@service/auth/AuthService'
import offlineWorkoutStorageService from '@service/workouts/OfflineWorkoutStorageService'
import useDailyWorkoutEntryStore from '@store/dailyWorkoutEntry/useDailyWorkoutEntryStore'
import useProgressStore from '@store/progress/useProgressStore'
import {create} from 'zustand'

export type AuthState = {
  userId: string | null
  userEmail: string | null
  isAuthed: boolean
  isAttemptingAuth: boolean
  initAuth: () => boolean
  loginOffline: (email?: string) => Promise<void>
  syncAuthState: (user: FirebaseAuthTypes.User | null) => void
  loginUser: (email: string, password: string) => Promise<void>
  registerUser: (email: string, password: string) => Promise<void>
  signInWithGoogle: () => Promise<void>
  signInWithApple: () => Promise<void>
  logoutUser: () => Promise<void>
  deleteUser: () => Promise<void>
}

const OFFLINE_USER_KEY = 'kf_offline_user'

// Clears everything owned by the previous account so a different login never
// sees stale data: server cache, unsynced workouts, and the in-progress workout.
const clearUserSession = async () => {
  await AsyncStorage.removeItem(OFFLINE_USER_KEY).catch(() => {})
  await offlineWorkoutStorageService.clear()
  queryClient.clear()
  useDailyWorkoutEntryStore.getState().reset()
  useProgressStore.getState().reset()
}

const useAuthStore = create<AuthState>()((set, get) => ({
  userId: null,
  userEmail: null,
  isAuthed: false,
  isAttemptingAuth: false,
  initAuth: () => {
    const user = authService.getCurrentUser()
    if (user !== null) {
      set({
        userId: user.uid,
        userEmail: user.email ?? null,
        isAuthed: true
      })
      return true
    }

    // Check stored offline session
    AsyncStorage.getItem(OFFLINE_USER_KEY).then(saved => {
      if (saved) {
        try {
          const parsed = JSON.parse(saved)
          set({
            userId: parsed.userId || 'offline-user-1',
            userEmail: parsed.userEmail || 'athlete@kineticfusion.com',
            isAuthed: true
          })
        } catch (e) {}
      }
    }).catch(() => {})

    return false
  },
  loginOffline: async (email?: string) => {
    const userEmail = email?.trim() || 'athlete@kineticfusion.com'
    const offlineUser = {
      userId: 'offline-user-1',
      userEmail
    }
    await AsyncStorage.setItem(OFFLINE_USER_KEY, JSON.stringify(offlineUser)).catch(() => {})
    set({
      userId: offlineUser.userId,
      userEmail: offlineUser.userEmail,
      isAuthed: true
    })
  },
  // Keeps the store in sync with Firebase's async auth state — cold-start
  // session restore (which initAuth's synchronous read can miss) and remote
  // sign-outs. Wired to authService.subscribeToAuthChanges in App.tsx.
  syncAuthState: user => {
    // Explicit login/registration flows own their state transitions —
    // registration in particular must not flip isAuthed before the backend
    // account is created (a failure there rolls the Firebase user back)
    if (get().isAttemptingAuth) return

    if (user !== null) {
      set({
        userId: user.uid,
        userEmail: user.email ?? null,
        isAuthed: true
      })
    }
  },
  loginUser: async (email, password) => {
    set({isAttemptingAuth: true})
    try {
      const user = await authService.logInUser(email, password)

      set({
        userId: user.id,
        userEmail: user.email,
        isAuthed: true
      })
    } catch (error) {
      // Fallback seamlessly to offline profile if remote server / network unavailable
      console.warn('[Auth] Remote login failed, activating offline session:', error)
      await get().loginOffline(email)
    } finally {
      set({isAttemptingAuth: false})
    }
  },
  registerUser: async (email, password) => {
    set({isAttemptingAuth: true})
    try {
      const account = await authService.registerUser(email, password)

      set({
        userId: account.id,
        userEmail: account.email,
        isAuthed: true
      })
    } catch (error) {
      // Fallback seamlessly to offline profile if remote server / network unavailable
      console.warn('[Auth] Remote registration failed, activating offline session:', error)
      await get().loginOffline(email)
    } finally {
      set({isAttemptingAuth: false})
    }
  },
  signInWithGoogle: async () => {
    set({isAttemptingAuth: true})
    try {
      const user = await authService.signInWithGoogle()

      if (!user) {
        return
      }

      set({
        userId: user.id,
        userEmail: user.email,
        isAuthed: true
      })
    } catch (error) {
      console.warn('[Auth] Google sign in failed, activating offline session:', error)
      await get().loginOffline()
    } finally {
      set({isAttemptingAuth: false})
    }
  },
  signInWithApple: async () => {
    set({isAttemptingAuth: true})
    try {
      const user = await authService.signInWithApple()

      if (!user) {
        return
      }

      set({
        userId: user.id,
        userEmail: user.email,
        isAuthed: true
      })
    } catch (error) {
      console.warn('[Auth] Apple sign in failed, activating offline session:', error)
      await get().loginOffline()
    } finally {
      set({isAttemptingAuth: false})
    }
  },
  logoutUser: async () => {
    await authService.logOutUser()
    await clearUserSession()

    set({
      userId: null,
      userEmail: null,
      isAuthed: false
    })
  },
  deleteUser: async () => {
    await authService.deleteCurrentUser().catch(() => {})
    await clearUserSession()

    set({
      userId: null,
      userEmail: null,
      isAuthed: false
    })
  }
}))

export default useAuthStore
