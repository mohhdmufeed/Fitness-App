import {DefaultTheme} from '@react-navigation/native'

// "Kinetic Fusion Dark Luxury" palette matching screenshot:
// Ultra dark obsidian background, charcoal cards, and muted olive/sage accent.
const page = '#0D0E11'
const card = '#16181B'
const inset = '#1C1E23'
const tile = '#1A1C20'
const track = '#202329'

const hairline = '#202227'
const inputBorder = '#272A31'
const grid = '#1A1C21'
const dashedBorder = '#3E434D'

const textPrimary = '#FFFFFF'
const textSecondary = '#8E939D'
const textMuted = '#6C717A'
const textFaint = '#4D5158'
const textDisabled = '#3B3E45'

// Olive / Sage accent matching screenshot CTA button (#8B9A60)
const green = '#8B9A60'
const teal = '#6E8A7D'
const lime = '#9EB16F'
const greenTint = '#1B2115'
const greenOnTint = '#A5B978'
const tealTint = '#16211C'
const danger = '#E2685E'
const dangerTint = '#39241F'
const primaryButtonText = '#11140C'

const white = '#ffffff'

export const Theme = {
  dark: true,
  fonts: DefaultTheme.fonts,
  colors: {
    ...DefaultTheme.colors,
    background: page,
    // Fully transparent `background` — pair with it in fade-out gradients
    backgroundTransparent: `${page}00`,
    primary: page,
    tertiary: card,
    secondary: hairline,
    secondaryLighter: green,
    white,
    text: textPrimary,
    navBar: '#0E0F12',
    chip: tile,
    border: hairline,
    fireOrange: '#FF9502',
    error: danger,
    errorLight: dangerTint,
    success: green,
    overlayBackdrop: '#000000',

    card,
    inset,
    tile,
    track,
    onInverse: primaryButtonText,
    primaryButtonText,
    hairline,
    inputBorder,
    grid,
    dashedBorder,
    textSecondary,
    textMuted,
    textFaint,
    textDisabled,
    accentGreen: green,
    teal,
    lime,
    greenTint,
    greenOnTint,
    tealTint,
    danger,
    dangerTint,
    barMuted: '#242A1D',
    barMid: '#58683E',
    barActive: green,
    loginGradientStart: '#0B0C0E',
    loginGradientEnd: '#101216'
  }
}
