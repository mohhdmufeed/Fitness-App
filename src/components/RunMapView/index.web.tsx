import React, {useMemo} from 'react'
import {View} from 'react-native'
import Svg, {Polyline as SvgPolyline} from 'react-native-svg'
import {Theme} from '@styles/theme'
import Text from '@components/Text'
import {RUN_MAP_EMPTY_TEXT} from '@constants/strings'
import styles from './index.styled'
import {MapPoint} from './index.util'

export type {MapPoint} from './index.util'

interface Props {
  route: MapPoint[]
  isLive?: boolean
  rounded?: boolean
}

const RunMapView = ({route, rounded = true}: Props) => {
  if (route.length === 0) {
    return (
      <View style={[styles.emptyContainer, rounded && styles.containerRounded]}>
        <Text style={styles.emptyText}>{RUN_MAP_EMPTY_TEXT}</Text>
      </View>
    )
  }

  const {minLat, maxLat, minLng, maxLng} = useMemo(() => {
    let minLat = route[0].latitude
    let maxLat = route[0].latitude
    let minLng = route[0].longitude
    let maxLng = route[0].longitude

    for (const point of route) {
      if (point.latitude < minLat) minLat = point.latitude
      if (point.latitude > maxLat) maxLat = point.latitude
      if (point.longitude < minLng) minLng = point.longitude
      if (point.longitude > maxLng) maxLng = point.longitude
    }

    return {minLat, maxLat, minLng, maxLng}
  }, [route])

  const svgPoints = useMemo(() => {
    const latSpan = Math.max(maxLat - minLat, 0.0001)
    const lngSpan = Math.max(maxLng - minLng, 0.0001)
    const width = 280
    const height = 180
    const padding = 20

    return route
      .map(p => {
        const x = padding + ((p.longitude - minLng) / lngSpan) * (width - 2 * padding)
        const y = height - (padding + ((p.latitude - minLat) / latSpan) * (height - 2 * padding))
        return `${x.toFixed(1)},${y.toFixed(1)}`
      })
      .join(' ')
  }, [route, minLat, maxLat, minLng, maxLng])

  return (
    <View
      style={[
        styles.container,
        rounded && styles.containerRounded,
        {overflow: 'hidden', backgroundColor: '#0f1713'}
      ]}>
      <Svg width="100%" height="100%" viewBox="0 0 280 180">
        <SvgPolyline
          points={svgPoints}
          fill="none"
          stroke={Theme.colors.accentGreen}
          strokeWidth="4"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </Svg>
    </View>
  )
}

export default RunMapView
