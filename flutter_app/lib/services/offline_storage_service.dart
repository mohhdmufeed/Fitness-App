import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../models/meal.dart';
import '../models/run_record.dart';
import '../models/user_profile.dart';

class OfflineStorageService {
  static const String _keyWorkouts = 'kf_workouts_list';
  static const String _keyTemplates = 'kf_templates_list';
  static const String _keyDailyMeals = 'kf_daily_meals_';
  static const String _keyRuns = 'kf_runs_list';
  static const String _keyWeights = 'kf_weights_list';
  static const String _keyProfile = 'kf_user_profile';

  // Workouts
  static Future<List<DailyWorkout>> loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyWorkouts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => DailyWorkout.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveWorkouts(List<DailyWorkout> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(workouts.map((w) => w.toJson()).toList());
    await prefs.setString(_keyWorkouts, raw);
  }

  // Templates
  static Future<List<WorkoutTemplate>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyTemplates);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => WorkoutTemplate.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTemplates(List<WorkoutTemplate> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(templates.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTemplates, raw);
  }

  // Meals for specific date
  static Future<List<Meal>> loadMealsForDate(String dateIso) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyDailyMeals$dateIso');
    if (raw == null || raw.isEmpty) {
      // Default 4 buckets
      return [
        Meal(id: 'b_$dateIso', type: MealType.breakfast, name: 'Breakfast'),
        Meal(id: 'l_$dateIso', type: MealType.lunch, name: 'Lunch'),
        Meal(id: 'd_$dateIso', type: MealType.dinner, name: 'Dinner'),
        Meal(id: 's_$dateIso', type: MealType.snacks, name: 'Snacks'),
      ];
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMealsForDate(String dateIso, List<Meal> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(meals.map((m) => m.toJson()).toList());
    await prefs.setString('$_keyDailyMeals$dateIso', raw);
  }

  // Runs
  static Future<List<RunRecord>> loadRuns() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyRuns);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => RunRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRuns(List<RunRecord> runs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(runs.map((r) => r.toJson()).toList());
    await prefs.setString(_keyRuns, raw);
  }

  // Bodyweight entries
  static Future<List<WeightEntry>> loadWeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyWeights);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => WeightEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveWeightEntries(List<WeightEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((w) => w.toJson()).toList());
    await prefs.setString(_keyWeights, raw);
  }

  // User Profile
  static Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProfile);
    if (raw == null || raw.isEmpty) {
      return UserProfile.defaultProfile();
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProfile.defaultProfile();
    }
  }

  static Future<UserProfile> loadUserProfile() => loadProfile();

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(profile.toJson());
    await prefs.setString(_keyProfile, raw);
  }

  static Future<void> saveUserProfile(UserProfile profile) => saveProfile(profile);
}

