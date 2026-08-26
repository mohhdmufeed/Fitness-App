import 'react-native-get-random-values'
import {Platform} from 'react-native'
import firebase from '@react-native-firebase/app'

if (Platform.OS === 'web') {
  const RN = require('react-native')
  const React = require('react')
  if (!RN.codegenNativeComponent) {
    RN.codegenNativeComponent = () => {
      return React.forwardRef((props, ref) => React.createElement(RN.View || 'div', {...props, ref}))
    }
  }
  if (!RN.requireNativeComponent) {
    RN.requireNativeComponent = () => {
      return React.forwardRef((props, ref) => React.createElement(RN.View || 'div', {...props, ref}))
    }
  }
  try {
    if (!firebase.apps || firebase.apps.length === 0) {
      firebase.initializeApp({
        apiKey: 'AIzaSyFakeKeyForWebClientMocking123',
        appId: '1:65554130864:web:mockAppId',
        projectId: 'kinetic-fusion',
        databaseURL: 'https://kinetic-fusion.firebaseio.com',
        messagingSenderId: '65554130864',
        storageBucket: 'kinetic-fusion.appspot.com'
      })
    }
  } catch (e) {
    // Ignore if already initialized or unavailable
  }
}

// Registers the background GPS TaskManager task at module top level so it
// fires even on headless/background relaunches (the app process the OS
// spins up just to deliver a location batch, without ever mounting <App/>).
// Must be imported before registerRootComponent, and must never be moved
// into a component/hook.
import './src/service/location/runLocationTask'

import {registerRootComponent} from 'expo'

import App from './App'

// registerRootComponent calls AppRegistry.registerComponent('main', () => App);
// It also ensures that whether you load the app in Expo Go or in a native build,
// the environment is set up appropriately
registerRootComponent(App)
