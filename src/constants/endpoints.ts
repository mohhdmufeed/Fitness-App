import {SOH_API_BASE_URL} from '@env'

// Host comes from the environment: local .env for `expo run`, EAS environment
// variables for builds (development/preview → dev API, production → prod).
// Fallback keeps release builds safe if the var is ever missing.
const baseApiUrl = `${SOH_API_BASE_URL || 'https://stateofhealthapi.com'}/api`

const Endpoints = {
  Exercises: `${baseApiUrl}/exercises`,
  Exercise: `${baseApiUrl}/exercise/`,
  Template: `${baseApiUrl}/template/`,
  Workout: `${baseApiUrl}/workout/`,
  WorkoutSummaries: `${baseApiUrl}/workouts/summary`,
  WeeklyWorkoutSummary: `${baseApiUrl}/workouts/weekly-summary/7`,
  ExerciseTemplates: `${baseApiUrl}/templates`,
  User: `${baseApiUrl}/user`,
  UserAvatar: `${baseApiUrl}/user/avatar`,
  Records: `${baseApiUrl}/records`,
  ExerciseHistory: (exerciseId: string) => `${baseApiUrl}/exercises/${exerciseId}/history`,
  Run: `${baseApiUrl}/run/`,
  Runs: `${baseApiUrl}/runs`,
  WeighIn: `${baseApiUrl}/weigh-in/`,
  WeighIns: `${baseApiUrl}/weigh-ins`,
  DailyMacros: (date: string) => `${baseApiUrl}/macros/${date}`,
  MacrosHistory: `${baseApiUrl}/macros/history`,
  MacroMealEntries: (mealId: string) => `${baseApiUrl}/macros/meal/${mealId}/entries`,
  MacroEntry: (entryId: string) => `${baseApiUrl}/macros/entry/${entryId}`,
  MacroEstimate: `${baseApiUrl}/macros/estimate`,
  AiUsage: `${baseApiUrl}/macros/ai-usage`,
  MacroLabelScan: `${baseApiUrl}/macros/label-scan`,
  MacroTargets: `${baseApiUrl}/user/targets`,
  Foods: `${baseApiUrl}/foods`,
  Food: (foodId: string) => `${baseApiUrl}/foods/${foodId}`,
  BrandedFoodSearch: (query: string) => `${baseApiUrl}/macros/search-branded-foods?q=${encodeURIComponent(query)}`
}

export default Endpoints
