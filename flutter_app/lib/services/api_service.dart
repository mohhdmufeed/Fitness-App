import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/meal.dart';
import '../models/workout.dart';


class ApiService {
  static const String baseUrl = 'https://w3fv96liu9.execute-api.us-east-2.amazonaws.com/prod';
  static const String usdaBaseUrl = 'https://api.nal.usda.gov/fdc/v1';

  static const String _jwtTokenKey = 'kf_jwt_token';

  // JWT Token Management
  static Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtTokenKey);
  }

  static Future<void> saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtTokenKey, token);
  }

  static Future<void> clearJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtTokenKey);
  }

  // Secure Header with JWT Bearer Token
  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getJwtToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Online Workouts Sync with JWT
  static Future<bool> syncWorkoutOnline(DailyWorkout workout) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/workouts');
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(workout.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      // Offline fallback: handled by local storage
      return false;
    }
  }

  // Online Macros Sync with JWT
  static Future<bool> syncMacrosOnline(String dateIso, List<Meal> meals) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/macros/$dateIso');
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(meals.map((m) => m.toJson()).toList()),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      // Offline fallback
      return false;
    }
  }

  // Online USDA Food Search
  static Future<List<FoodItem>> searchUsdaFoodOnline(String query) async {
    try {
      final url = Uri.parse('$usdaBaseUrl/foods/search?query=${Uri.encodeComponent(query)}&pageSize=10');
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foods = (data['foods'] as List<dynamic>?) ?? [];

        return foods.map((f) {
          final nutrients = (f['foodNutrients'] as List<dynamic>?) ?? [];
          double calories = 0, protein = 0, carbs = 0, fat = 0;

          for (final n in nutrients) {
            final name = (n['nutrientName'] as String?)?.toLowerCase() ?? '';
            final val = (n['value'] as num?)?.toDouble() ?? 0.0;
            if (name.contains('energy')) calories = val;
            if (name.contains('protein')) protein = val;
            if (name.contains('carbohydrate')) carbs = val;
            if (name.contains('lipid') || name.contains('fat')) fat = val;
          }

          return FoodItem(
            id: f['fdcId']?.toString() ?? const Uuid().v4(),
            name: f['description'] ?? query,
            quantityText: '100g',
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
          );

        }).toList();
      }
    } catch (_) {
      // Fallback to on-device AI estimator
    }
    return [];
  }
}
