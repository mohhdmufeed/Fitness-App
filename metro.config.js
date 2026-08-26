const {getDefaultConfig} = require('@expo/metro-config')
const path = require('path')

const defaultConfig = getDefaultConfig(__dirname)

defaultConfig.resolver.sourceExts.push('cjs')
defaultConfig.resolver.extraNodeModules = {
  ...defaultConfig.resolver.extraNodeModules,
  'react-native-linear-gradient': path.resolve(__dirname, 'src/utility/linearGradientShim.js'),
  'react-native/Libraries/Utilities/codegenNativeComponent': path.resolve(
    __dirname,
    'src/utility/codegenNativeComponentShim.js'
  ),
  'react-native-keyboard-aware-scroll-view': path.resolve(
    __dirname,
    'src/utility/keyboardAwareScrollViewShim.js'
  )
}

module.exports = defaultConfig
