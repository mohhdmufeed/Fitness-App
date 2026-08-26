const React = require('react')
const {View} = require('react-native')

function codegenNativeComponent() {
  return React.forwardRef((props, ref) => React.createElement(View, {...props, ref}))
}

codegenNativeComponent.__esModule = true
codegenNativeComponent.default = codegenNativeComponent

module.exports = codegenNativeComponent
