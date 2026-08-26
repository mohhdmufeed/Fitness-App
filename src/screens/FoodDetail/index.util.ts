export type MacroKey = 'protein' | 'carbs' | 'fat'

export interface PerServingMacros {
  calories: number
  protein: number
  carbs: number
  fat: number
}

export interface MacroBreakdownSlice {
  key: MacroKey
  grams: number
  // This macro's share of total calories, 0..1
  calorieShare: number
  // calorieShare rounded to a whole percent, 0..100
  percent: number
}

export interface DonutSegment {
  key: MacroKey
  startFraction: number
  lengthFraction: number
}

export interface ServingFraction {
  glyph: string
  value: number
}

export const MIN_SERVINGS = 0.25

export const SERVING_FRACTIONS: ServingFraction[] = [
  {glyph: '¼', value: 0.25},
  {glyph: '⅓', value: 0.33},
  {glyph: '½', value: 0.5},
  {glyph: '⅔', value: 0.66},
  {glyph: '¾', value: 0.75}
]

export const MACRO_LABELS: Record<MacroKey, string> = {
  protein: 'Protein',
  carbs: 'Carbs',
  fat: 'Fat'
}

const FRACTION_EPSILON = 0.001

const DONUT_GAP_FRACTION = 0.02

// Keeps stepper/chip math away from floating point dust (0.30000000000000004)
const roundServings = (servings: number): number => Math.round(servings * 100) / 100

export const getFractionalPart = (servings: number): number => roundServings(servings - Math.floor(servings))

// 1 -> '1', 1.5 -> '1½', 0.25 -> '¼', 1.2 -> '1.2'
export const formatServingsDisplay = (servings: number): string => {
  const whole = Math.floor(servings)
  const fraction = getFractionalPart(servings)

  if (fraction === 0) {
    return String(whole)
  }

  const glyph = SERVING_FRACTIONS.find(f => Math.abs(f.value - fraction) < FRACTION_EPSILON)?.glyph

  if (!glyph) {
    return String(roundServings(servings))
  }

  return whole === 0 ? glyph : `${whole}${glyph}`
}

// Each whole number splits into the same stops as the fraction chips:
// 1 -> 1¼ -> 1⅓ -> 1½ -> 1⅔ -> 1¾ -> 2
const STEP_FRACTIONS = [0, ...SERVING_FRACTIONS.map(f => f.value)]

export const stepServings = (servings: number, direction: 1 | -1): number => {
  const whole = Math.floor(servings)
  const fraction = getFractionalPart(servings)

  if (direction === 1) {
    const next = STEP_FRACTIONS.find(f => f > fraction + FRACTION_EPSILON)

    return roundServings(next === undefined ? whole + 1 : whole + next)
  }

  const prev = [...STEP_FRACTIONS].reverse().find(f => f < fraction - FRACTION_EPSILON)
  const stepped = prev === undefined ? whole - 1 + 0.75 : whole + prev

  return Math.max(MIN_SERVINGS, roundServings(stepped))
}

// Replaces only the fractional part, keeping the whole part: 1.5 + ¼ -> 1.25
export const applyFractionPart = (servings: number, fraction: number): number =>
  roundServings(Math.floor(servings) + fraction)

export const isFractionSelected = (servings: number, fraction: number): boolean =>
  Math.abs(getFractionalPart(servings) - fraction) < FRACTION_EPSILON

export const buildMacroBreakdown = (protein: number, carbs: number, fat: number): MacroBreakdownSlice[] => {
  const slices: {key: MacroKey; grams: number; calories: number}[] = [
    {key: 'protein', grams: protein, calories: protein * 4},
    {key: 'carbs', grams: carbs, calories: carbs * 4},
    {key: 'fat', grams: fat, calories: fat * 9}
  ]

  const totalCalories = slices.reduce((sum, slice) => sum + slice.calories, 0)

  return slices.map(slice => {
    const calorieShare = totalCalories === 0 ? 0 : slice.calories / totalCalories

    return {
      key: slice.key,
      grams: slice.grams,
      calorieShare,
      percent: Math.round(calorieShare * 100)
    }
  })
}

export const dominantMacroKey = (slices: MacroBreakdownSlice[]): MacroKey =>
  slices.reduce((best, slice) => (slice.calorieShare > best.calorieShare ? slice : best), slices[0]).key

// Lays the visible slices around the ring, leaving a small gap between arcs.
// Fractions are of the full circumference; zero slices are dropped.
export const buildDonutSegments = (
  slices: MacroBreakdownSlice[],
  gapFraction: number = DONUT_GAP_FRACTION
): DonutSegment[] => {
  const visible = slices.filter(slice => slice.calorieShare > 0)

  if (visible.length === 0) {
    return []
  }

  const gap = visible.length > 1 ? gapFraction : 0
  const available = 1 - gap * visible.length
  let cursor = 0

  return visible.map(slice => {
    const segment: DonutSegment = {
      key: slice.key,
      startFraction: cursor,
      lengthFraction: slice.calorieShare * available
    }

    cursor += segment.lengthFraction + gap

    return segment
  })
}

export const scaleMacros = (perServing: PerServingMacros, servings: number): PerServingMacros => ({
  calories: Math.round(perServing.calories * servings),
  protein: Math.round(perServing.protein * servings),
  carbs: Math.round(perServing.carbs * servings),
  fat: Math.round(perServing.fat * servings)
})

// '2g P · 75g C · 5g F'
export const formatMacroSummary = (protein: number, carbs: number, fat: number): string =>
  `${Math.round(protein)}g P · ${Math.round(carbs)}g C · ${Math.round(fat)}g F`

// 'Chobani · 1 cup · 231 cal per serving' (brand and serving text omitted when missing)
export const formatDetailSubtitle = (
  brand: string | null,
  servingText: string | null,
  calories: number,
  calSuffix: string
): string => {
  const calText = `${Math.round(calories)} ${calSuffix}`

  return [brand, servingText, calText].filter(Boolean).join(' · ')
}
