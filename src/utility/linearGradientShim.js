const React = require('react')
const {LinearGradient: ExpoLG} = require('expo-linear-gradient')

const LinearGradientComponent = ExpoLG || function LinearGradient(props) {
  const {colors = ['#000', '#000'], style, children, ...rest} = props
  const background = `linear-gradient(180deg, ${colors.join(', ')})`
  return React.createElement('div', {style: [{background}, style], ...rest}, children)
}

LinearGradientComponent.default = LinearGradientComponent
LinearGradientComponent.LinearGradient = LinearGradientComponent
LinearGradientComponent.__esModule = true

module.exports = LinearGradientComponent
