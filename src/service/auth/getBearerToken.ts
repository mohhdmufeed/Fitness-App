import auth from '@react-native-firebase/auth'

export const getBearerToken = (forceRefresh: boolean = false) => {
  try {
    return auth().currentUser?.getIdToken(forceRefresh)
  } catch {
    return Promise.resolve(undefined)
  }
}
