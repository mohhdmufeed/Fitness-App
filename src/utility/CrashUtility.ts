import crashlytics from '@react-native-firebase/crashlytics'

export default class CrashUtility {
  public static recordError(error: any | unknown) {
    try {
      crashlytics().recordError(error)
    } catch {
      console.error(error)
    }
  }
}
