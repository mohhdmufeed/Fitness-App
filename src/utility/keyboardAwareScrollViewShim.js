const React = require('react')
const {ScrollView, FlatList, SectionList} = require('react-native')

const KeyboardAwareScrollView = React.forwardRef((props, ref) => {
  return React.createElement(ScrollView, {...props, ref})
})

const KeyboardAwareFlatList = React.forwardRef((props, ref) => {
  return React.createElement(FlatList, {...props, ref})
})

const KeyboardAwareSectionList = React.forwardRef((props, ref) => {
  return React.createElement(SectionList, {...props, ref})
})

module.exports = {
  __esModule: true,
  default: KeyboardAwareScrollView,
  KeyboardAwareScrollView,
  KeyboardAwareFlatList,
  KeyboardAwareSectionList,
  listenToKeyboardEvents: () => Comp => Comp
}
