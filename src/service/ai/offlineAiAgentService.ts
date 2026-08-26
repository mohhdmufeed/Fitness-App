import offlineMacroStorageService from '@service/macros/OfflineMacroStorageService'
import offlineWorkoutStorageService from '@service/workouts/OfflineWorkoutStorageService'

export interface AgentMessage {
  id: string
  role: 'user' | 'agent'
  content: string
  timestamp: number
  suggestions?: string[]
}

export class OfflineAiAgentService {
  /**
   * Generates intelligent, evidence-based fitness & nutrition answers completely offline.
   */
  async processQuery(query: string, history: AgentMessage[] = []): Promise<AgentMessage> {
    const q = query.toLowerCase().trim()
    const timestamp = Date.now()
    const id = `msg-${timestamp}-${Math.random().toString(36).substring(2, 6)}`

    // 1. Protein / Macros queries
    if (q.includes('protein') || q.includes('macros') || q.includes('eat') || q.includes('diet') || q.includes('calorie')) {
      const todayIso = new Date().toISOString().split('T')[0]
      const dailyMacros = await offlineMacroStorageService.getDailyMacros(todayIso).catch(() => null)
      
      let contextNote = ''
      if (dailyMacros) {
        const remainingProtein = Math.max(0, (dailyMacros.targets.protein ?? 160) - dailyMacros.totals.protein)
        const remainingCals = Math.max(0, (dailyMacros.targets.calories ?? 2370) - dailyMacros.totals.calories)
        contextNote = `\n\n📊 **Your Progress Today:**\n• Consumed: ${dailyMacros.totals.calories} / ${dailyMacros.targets.calories ?? 2370} kcal\n• Protein: ${dailyMacros.totals.protein}g / ${dailyMacros.targets.protein ?? 160}g (${remainingProtein}g remaining)`
      }

      if (q.includes('protein source') || q.includes('high protein') || q.includes('hit protein')) {
        return {
          id,
          role: 'agent',
          content: `To hit high protein targets efficiently, aim for lean, high-bioavailability sources:${contextNote}\n\n🥩 **Top Protein Sources:**\n• **Chicken Breast:** ~31g protein per 100g (165 kcal)\n• **Egg Whites:** ~3.6g protein per white (17 kcal)\n• **Whey/Plant Isolate:** ~24g protein per scoop (120 kcal)\n• **0% Greek Yogurt:** ~17g protein per 170g (100 kcal)\n• **Cottage Cheese:** ~14g protein per 110g (90 kcal)\n• **Atlantic Salmon / Tuna:** ~22-28g protein per 100g\n\n💡 **Tip:** Distribute protein across 3–4 meals with ~30-40g per feeding for optimal muscle protein synthesis (MPS).`,
          timestamp,
          suggestions: ['Give me a high-protein meal idea', 'How many calories should I eat?', 'Log with AI']
        }
      }

      if (q.includes('post-workout') || q.includes('pre-workout') || q.includes('post workout')) {
        return {
          id,
          role: 'agent',
          content: `Optimal nutrition timing around training:${contextNote}\n\n⚡ **Pre-Workout (1-2h before):**\n• Easily digestible carbs + moderate protein (e.g. oatmeal with whey, or banana with rice cakes).\n\n💪 **Post-Workout (within 2h):**\n• 30–40g fast-digesting protein + 40–60g carbohydrates to replenish glycogen and trigger muscle repair (e.g. Whey protein shake with banana, or chicken breast with jasmine rice).`,
          timestamp,
          suggestions: ['What about hydration?', 'How much rest between sets?']
        }
      }

      return {
        id,
        role: 'agent',
        content: `Here is your offline nutrition summary:${contextNote}\n\n🎯 **General Rules for Hypertrophy & Fat Loss:**\n• **Protein:** 1.6 – 2.2g per kg of body weight (0.8–1g per lb).\n• **Carbohydrates:** 3–5g per kg to fuel high-intensity training.\n• **Fats:** 0.6–1g per kg for hormonal balance and joint health.\n\nUse the **Log with AI** feature in the Macros tab to estimate any meal description on-device!`,
        timestamp,
        suggestions: ['High protein food list', 'Workout recommendations', 'Check today targets']
      }
    }

    // 2. Workout / Training / Split queries
    if (q.includes('workout') || q.includes('split') || q.includes('routine') || q.includes('hypertrophy') || q.includes('strength') || q.includes('train')) {
      if (q.includes('split') || q.includes('routine') || q.includes('program')) {
        return {
          id,
          role: 'agent',
          content: `Here are two recommended science-backed training splits based on your recovery trajectory:\n\n🏋️‍♂️ **Option A: 4-Day Upper / Lower Split (Recommended)**\n• **Day 1:** Upper Strength (Bench, Barbell Rows, Overhead Press, Pull-ups)\n• **Day 2:** Lower Strength (Squat, Romanian Deadlift, Leg Press, Calves)\n• **Day 3:** Rest / Zone 2 Cardio\n• **Day 4:** Upper Hypertrophy (Incline DB Press, Cable Rows, Lateral Raises, Arms)\n• **Day 5:** Lower Hypertrophy (Leg Extension, Hamstring Curls, Lunges)\n• **Days 6-7:** Active Recovery\n\n🔥 **Option B: 3-Day Full Body**\n• Monday / Wednesday / Friday full body with 48 hours recovery between sessions.`,
          timestamp,
          suggestions: ['How to progressive overload?', 'Optimal rep range for growth', 'Protein recommendations']
        }
      }

      if (q.includes('rep') || q.includes('set') || q.includes('volume') || q.includes('rpe')) {
        return {
          id,
          role: 'agent',
          content: `🎯 **Optimal Hypertrophy Parameters:**\n\n• **Rep Range:** 6–12 reps for compound lifts; 10–20 reps for isolation movements.\n• **Intensity (RPE):** Train with RPE 7.5 – 9.0 (1–3 reps in reserve / RIR).\n• **Weekly Volume:** 12–20 hard sets per muscle group per week, split across 2+ sessions.\n• **Rest Periods:** 2–3 minutes for compound multi-joint lifts; 60–90 seconds for isolation.\n\n📈 **Progressive Overload:** Increase weight or add 1 rep each session when you hit the top of your target rep range.`,
          timestamp,
          suggestions: ['Show me 4-day split', 'How to recover faster?', 'Nutrition timing']
        }
      }

      return {
        id,
        role: 'agent',
        content: `💪 **Kinetic Fusion Training Intelligence:**\n\nYour workouts are logged with full set-by-set weight, reps, and RPE tracking.\n\n• **Today's Focus:** High-tension compound strength followed by metabolic isolation.\n• **Recovery Status:** Normal training trajectory.\n\nTap **"Start workout"** on the Train tab to begin logging your session with offline SQLite persistence!`,
        timestamp,
        suggestions: ['Recommend training split', 'Best post-workout meal', 'How to prevent muscle soreness?']
      }
    }

    // 3. Recovery / Sleep / Soreness queries
    if (q.includes('recovery') || q.includes('sleep') || q.includes('sore') || q.includes('doms') || q.includes('cardio') || q.includes('run')) {
      return {
        id,
        role: 'agent',
        content: `🧠 **Recovery & Adaptation Protocol:**\n\n1. **Sleep:** Aim for 7.5 – 9 hours nightly. Growth hormone (GH) and deep tissue repair peak during slow-wave NREM sleep.\n2. **Hydration:** Consume 3–4 liters of water daily plus electrolytes during intense sweating.\n3. **Active Recovery:** 20–30 minutes of low-intensity Zone 2 cardio (or walking) increases blood flow and clears metabolic byproducts without adding systemic fatigue.\n4. **Deload Strategy:** If fatigue accumulates or joints ache, reduce volume by 40-50% for 1 week every 6–8 weeks.`,
        timestamp,
        suggestions: ['Show training split', 'What to eat after training?', 'Track a run']
      }
    }

    // Default friendly offline AI assistant response
    return {
      id,
      role: 'agent',
      content: `Hello! I am your **Kinetic Fusion On-Device AI Fitness Coach**.\n\nI can help you with:\n• 🥗 **Nutrition & Macros:** Meal planning, protein recommendations, and macro estimation.\n• 🏋️ **Workout Programming:** Splits (Upper/Lower, PPL, Full Body), rep ranges, and progressive overload.\n• ⚡ **Recovery & Performance:** Sleep optimization, fatigue management, and Zone 2 running.\n\nWhat would you like to focus on today?`,
      timestamp,
      suggestions: ['Recommend a 4-day workout split', 'How much protein do I need?', 'What is a good post-workout meal?']
    }
  }
}

const offlineAiAgentService = new OfflineAiAgentService()
export default offlineAiAgentService
