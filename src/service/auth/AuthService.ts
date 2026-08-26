import {AuthError, AuthErrorPathEnum} from '@data/models/AuthError'
import User, {CreateUserPayload} from '@data/models/User'
import {createUser} from '@queries/api/auth/createUser'
import auth, {FirebaseAuthTypes} from '@react-native-firebase/auth'
import {GoogleSignin} from '@react-native-google-signin/google-signin'
import CrashUtility from '@utility/CrashUtility'
import * as AppleAuthentication from 'expo-apple-authentication'
import * as Crypto from 'expo-crypto'

import {GOOGLE_WEB_CLIENT_ID} from '@constants/auth'

import {decodeAuthError} from './AuthErrorEnum'

// A real Error (so instanceof / CrashUtility.recordError work) carrying the
// AuthError fields the auth screens read via isAuthError()
const createAuthError = (errorPath: AuthErrorPathEnum, errorCode: string): Error & AuthError => {
  const errorMessage = decodeAuthError(errorCode)

  return Object.assign(new Error(errorMessage), {
    errorPath,
    errorDate: Date.now(),
    errorCode,
    errorMessage
  })
}

let isGoogleSignInConfigured = false

const ensureGoogleSignInConfigured = () => {
  if (isGoogleSignInConfigured) {
    return
  }

  GoogleSignin.configure({webClientId: GOOGLE_WEB_CLIENT_ID})
  isGoogleSignInConfigured = true
}

class AuthService {
  async registerUser(email: string, password: string): Promise<User> {
    let registeredUser: CreateUserPayload = {
      userId: '',
      email: ''
    }

    try {
      const {user} = await auth().createUserWithEmailAndPassword(email, password)

      registeredUser = {
        userId: user.uid,
        email: user.email ?? ''
      }
    } catch (e) {
      const error = e as FirebaseAuthTypes.NativeFirebaseAuthError

      throw createAuthError(AuthErrorPathEnum.REGISTRATION, error.code)
    }

    try {
      await createUser(registeredUser)

      return {
        id: registeredUser.userId,
        email: registeredUser.email
      }
    } catch (error) {
      // Roll back the Firebase account so the email isn't left claimed by a
      // half-created account; the original backend error is what propagates
      await this.deleteCurrentUser().catch(rollbackError => CrashUtility.recordError(rollbackError))
      throw error
    }
  }

  async logInUser(email: string, password: string): Promise<User> {
    try {
      const userCredential = await auth().signInWithEmailAndPassword(email, password)
      const {user} = userCredential

      return {
        id: user.uid,
        name: user.displayName,
        email: user.email ?? ''
      }
    } catch (e) {
      const error = e as FirebaseAuthTypes.NativeFirebaseAuthError

      throw createAuthError(AuthErrorPathEnum.LOGIN, error.code)
    }
  }

  /** Resolves null when the user dismisses the Google account picker. */
  async signInWithGoogle(): Promise<User | null> {
    let userCredential: FirebaseAuthTypes.UserCredential

    try {
      ensureGoogleSignInConfigured()
      await GoogleSignin.hasPlayServices({showPlayServicesUpdateDialog: true})

      const response = await GoogleSignin.signIn()

      if (response.type === 'cancelled') {
        return null
      }

      const {idToken} = response.data

      if (!idToken) {
        throw new Error('Google sign-in returned no ID token')
      }

      const credential = auth.GoogleAuthProvider.credential(idToken)

      userCredential = await auth().signInWithCredential(credential)
    } catch (e) {
      const error = e as FirebaseAuthTypes.NativeFirebaseAuthError

      throw createAuthError(AuthErrorPathEnum.LOGIN, error.code)
    }

    const {user} = userCredential

    if (userCredential.additionalUserInfo?.isNewUser) {
      try {
        await createUser({
          userId: user.uid,
          email: user.email ?? ''
        })
      } catch (error) {
        // Roll back the just-created Firebase account so a retry re-runs
        // backend user creation; the original backend error is what propagates
        await this.deleteCurrentUser().catch(rollbackError => CrashUtility.recordError(rollbackError))
        throw error
      }
    }

    return {
      id: user.uid,
      name: user.displayName,
      email: user.email ?? ''
    }
  }

  /** Resolves null when the user dismisses the Apple sign-in sheet. */
  async signInWithApple(): Promise<User | null> {
    let userCredential: FirebaseAuthTypes.UserCredential
    let appleFullName: AppleAuthentication.AppleAuthenticationFullName | null = null

    try {
      // Firebase verifies the raw nonce against the SHA256 hash embedded in
      // Apple's identity token, tying the token to this sign-in attempt
      const rawNonce = Crypto.randomUUID()
      const hashedNonce = await Crypto.digestStringAsync(Crypto.CryptoDigestAlgorithm.SHA256, rawNonce)

      const appleCredential = await AppleAuthentication.signInAsync({
        requestedScopes: [
          AppleAuthentication.AppleAuthenticationScope.FULL_NAME,
          AppleAuthentication.AppleAuthenticationScope.EMAIL
        ],
        nonce: hashedNonce
      })

      appleFullName = appleCredential.fullName

      const {identityToken} = appleCredential

      if (!identityToken) {
        throw new Error('Apple sign-in returned no identity token')
      }

      const credential = auth.AppleAuthProvider.credential(identityToken, rawNonce)

      userCredential = await auth().signInWithCredential(credential)
    } catch (e) {
      if ((e as {code?: string}).code === 'ERR_REQUEST_CANCELED') {
        return null
      }

      const error = e as FirebaseAuthTypes.NativeFirebaseAuthError

      throw createAuthError(AuthErrorPathEnum.LOGIN, error.code)
    }

    const {user} = userCredential

    if (userCredential.additionalUserInfo?.isNewUser) {
      // Apple only shares the name on the very first authorization, so this is
      // the only chance to store it on the Firebase profile
      const displayName = [appleFullName?.givenName, appleFullName?.familyName].filter(Boolean).join(' ')

      if (displayName) {
        await user.updateProfile({displayName}).catch(error => CrashUtility.recordError(error))
      }

      try {
        await createUser({
          userId: user.uid,
          email: user.email ?? ''
        })
      } catch (error) {
        // Roll back the just-created Firebase account so a retry re-runs
        // backend user creation; the original backend error is what propagates
        await this.deleteCurrentUser().catch(rollbackError => CrashUtility.recordError(rollbackError))
        throw error
      }
    }

    return {
      id: user.uid,
      name: user.displayName,
      email: user.email ?? ''
    }
  }

  async sendPasswordResetEmail(email: string): Promise<void> {
    try {
      await auth().sendPasswordResetEmail(email)
    } catch (e) {
      const error = e as FirebaseAuthTypes.NativeFirebaseAuthError

      throw createAuthError(AuthErrorPathEnum.PASSWORD_RESET, error.code)
    }
  }

  getCurrentUser() {
    try {
      return auth().currentUser
    } catch {
      return null
    }
  }

  /** Subscribes to Firebase auth state (cold-start restore, remote sign-out). Returns the unsubscribe function. */
  subscribeToAuthChanges(listener: (user: FirebaseAuthTypes.User | null) => void): () => void {
    try {
      return auth().onAuthStateChanged(listener)
    } catch {
      return () => {}
    }
  }

  async logOutUser() {
    await auth().signOut()

    // Best-effort: clears the cached Google account so the next Google
    // sign-in shows the account picker instead of silently reusing it
    try {
      ensureGoogleSignInConfigured()
      await GoogleSignin.signOut()
    } catch (error) {
      CrashUtility.recordError(error)
    }
  }

  async deleteCurrentUser() {
    const currentUser = auth().currentUser

    if (!currentUser) {
      // A silent no-op here would let the caller believe the account was
      // deleted when it wasn't
      throw createAuthError(AuthErrorPathEnum.DELETE, 'auth/no-current-user')
    }

    try {
      await currentUser.delete()
    } catch (e) {
      const error = e as FirebaseAuthTypes.NativeFirebaseAuthError

      throw createAuthError(AuthErrorPathEnum.DELETE, error.code)
    }
  }
}

const authService = new AuthService()

export default authService
