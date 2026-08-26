import React from 'react'

import Svg, {Path} from 'react-native-svg'

import {IconProps} from './IconProps'

const StepsIcon = ({color, size = 17, strokeWidth = 2}: IconProps) => (
  <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <Path
      d="M8 3.5c1.5 0 2.4 1.4 2.4 3.2 0 1.4-.55 2.3-.65 3.8h-3.5C6.15 9 5.6 8.1 5.6 6.7c0-1.8.9-3.2 2.4-3.2z"
      stroke={color}
      strokeWidth={strokeWidth}
      strokeLinejoin="round"
    />

    <Path d="M6.55 12.6h2.9v1a1.45 1.45 0 01-2.9 0z" stroke={color} strokeWidth={strokeWidth} strokeLinejoin="round" />

    <Path
      d="M16.4 8.5c1.5 0 2.4 1.4 2.4 3.2 0 1.4-.55 2.3-.65 3.8h-3.5c-.1-1.5-.65-2.4-.65-3.8 0-1.8.9-3.2 2.4-3.2z"
      stroke={color}
      strokeWidth={strokeWidth}
      strokeLinejoin="round"
    />

    <Path d="M14.95 17.6h2.9v1a1.45 1.45 0 01-2.9 0z" stroke={color} strokeWidth={strokeWidth} strokeLinejoin="round" />
  </Svg>
)

export default StepsIcon
