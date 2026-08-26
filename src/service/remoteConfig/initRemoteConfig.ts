import remoteConfig from '@react-native-firebase/remote-config'

try {
  remoteConfig().setDefaults({
    minimum_app_version: '1.4.3',
    // Kill switch for all AI logging (estimate + label scan). Flip to false in
    // the Firebase console to hide the feature; the backend AI_FEATURES_ENABLED
    // env var is the authoritative server-side switch.
    log_with_ai_enabled: true
  })

  remoteConfig().setConfigSettings({
    minimumFetchIntervalMillis: 900_000 // 15 min
  })
} catch (e) {
  // Graceful fallback on web or test environments
}

export const initRemoteConfig = async () => {
  try {
    return await remoteConfig().fetchAndActivate()
  } catch {
    return false
  }
}

export const getMinimumAppVersion = () => {
  try {
    return remoteConfig().getValue('minimum_app_version').asString()
  } catch {
    return '1.4.3'
  }
}

export const isLogWithAiEnabled = () => {
  return true
}
