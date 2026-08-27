import 'package:uuid/uuid.dart';
import '../models/meal.dart';

class FoodNutritionInfo {
  final List<String> keywords;
  final String defaultServing;
  final double defaultGrams;
  final bool isUnitBased;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodNutritionInfo({
    required this.keywords,
    required this.defaultServing,
    required this.defaultGrams,
    this.isUnitBased = false,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class OfflineAiEstimator {
  static const _uuid = Uuid();

  static const Map<String, FoodNutritionInfo> _database = {
    'egg': FoodNutritionInfo(
      keywords: ['egg', 'eggs', 'boiled egg', 'fried egg', 'scrambled egg'],
      defaultServing: '1 large',
      defaultGrams: 50,
      isUnitBased: true,
      calories: 72,
      protein: 6.3,
      carbs: 0.4,
      fat: 4.8,
    ),
    'egg_white': FoodNutritionInfo(
      keywords: ['egg white', 'egg whites'],
      defaultServing: '1 white',
      defaultGrams: 33,
      isUnitBased: true,
      calories: 17,
      protein: 3.6,
      carbs: 0.2,
      fat: 0.1,
    ),
    'chicken_breast': FoodNutritionInfo(
      keywords: ['chicken breast', 'chicken', 'grilled chicken', 'baked chicken'],
      defaultServing: '100g',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6,
    ),
    'chicken_thigh': FoodNutritionInfo(
      keywords: ['chicken thigh', 'chicken thighs'],
      defaultServing: '100g',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 209,
      protein: 26,
      carbs: 0,
      fat: 10.9,
    ),
    'steak_beef': FoodNutritionInfo(
      keywords: ['steak', 'beef', 'ground beef', 'mince', 'ribeye', 'sirloin'],
      defaultServing: '100g',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 250,
      protein: 26,
      carbs: 0,
      fat: 15,
    ),
    'salmon': FoodNutritionInfo(
      keywords: ['salmon', 'grilled salmon', 'smoked salmon', 'fish'],
      defaultServing: '100g',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 208,
      protein: 22,
      carbs: 0,
      fat: 13,
    ),
    'tuna': FoodNutritionInfo(
      keywords: ['tuna', 'canned tuna', 'tuna fish'],
      defaultServing: '100g',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 130,
      protein: 28,
      carbs: 0,
      fat: 1,
    ),
    'rice': FoodNutritionInfo(
      keywords: ['rice', 'white rice', 'brown rice', 'jasmine rice', 'basmati rice'],
      defaultServing: '1 cup cooked',
      defaultGrams: 150,
      isUnitBased: false,
      calories: 130,
      protein: 2.7,
      carbs: 28,
      fat: 0.3,
    ),
    'oats': FoodNutritionInfo(
      keywords: ['oats', 'oatmeal', 'porridge', 'rolled oats'],
      defaultServing: '40g',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 389,
      protein: 16.9,
      carbs: 66.3,
      fat: 6.9,
    ),
    'bread': FoodNutritionInfo(
      keywords: ['bread', 'toast', 'sourdough', 'whole wheat bread', 'white bread'],
      defaultServing: '1 slice',
      defaultGrams: 40,
      isUnitBased: true,
      calories: 80,
      protein: 3.5,
      carbs: 15,
      fat: 1,
    ),
    'protein_powder': FoodNutritionInfo(
      keywords: ['whey', 'whey protein', 'protein powder', 'protein shake', 'casein'],
      defaultServing: '1 scoop (30g)',
      defaultGrams: 30,
      isUnitBased: true,
      calories: 120,
      protein: 24,
      carbs: 3,
      fat: 1.5,
    ),
    'milk': FoodNutritionInfo(
      keywords: ['milk', 'whole milk', 'skim milk', 'low fat milk'],
      defaultServing: '1 cup (240ml)',
      defaultGrams: 240,
      isUnitBased: false,
      calories: 50,
      protein: 3.4,
      carbs: 4.8,
      fat: 2,
    ),
    'almond_milk': FoodNutritionInfo(
      keywords: ['almond milk', 'oat milk', 'soy milk'],
      defaultServing: '1 cup (240ml)',
      defaultGrams: 240,
      isUnitBased: false,
      calories: 30,
      protein: 1,
      carbs: 1.5,
      fat: 2.5,
    ),
    'greek_yogurt': FoodNutritionInfo(
      keywords: ['greek yogurt', 'yogurt', 'curd'],
      defaultServing: '150g',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 90,
      protein: 15,
      carbs: 5,
      fat: 0.5,
    ),
    'peanut_butter': FoodNutritionInfo(
      keywords: ['peanut butter', 'almond butter', 'pb'],
      defaultServing: '1 tbsp (16g)',
      defaultGrams: 16,
      isUnitBased: true,
      calories: 95,
      protein: 4,
      carbs: 3.5,
      fat: 8,
    ),
    'banana': FoodNutritionInfo(
      keywords: ['banana', 'bananas'],
      defaultServing: '1 medium (118g)',
      defaultGrams: 118,
      isUnitBased: true,
      calories: 105,
      protein: 1.3,
      carbs: 27,
      fat: 0.3,
    ),
    'apple': FoodNutritionInfo(
      keywords: ['apple', 'apples'],
      defaultServing: '1 medium (180g)',
      defaultGrams: 180,
      isUnitBased: true,
      calories: 95,
      protein: 0.5,
      carbs: 25,
      fat: 0.3,
    ),
    'potato': FoodNutritionInfo(
      keywords: ['potato', 'potatoes', 'sweet potato', 'baked potato'],
      defaultServing: '1 medium (150g)',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 86,
      protein: 1.6,
      carbs: 20,
      fat: 0.1,
    ),
    'pasta': FoodNutritionInfo(
      keywords: ['pasta', 'spaghetti', 'noodles', 'macaroni'],
      defaultServing: '1 cup cooked (140g)',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 158,
      protein: 5.8,
      carbs: 31,
      fat: 0.9,
    ),
    'pizza': FoodNutritionInfo(
      keywords: ['pizza', 'slice of pizza'],
      defaultServing: '1 slice (107g)',
      defaultGrams: 107,
      isUnitBased: true,
      calories: 285,
      protein: 12,
      carbs: 36,
      fat: 10,
    ),
    'burger': FoodNutritionInfo(
      keywords: ['burger', 'cheeseburger', 'hamburger'],
      defaultServing: '1 burger',
      defaultGrams: 200,
      isUnitBased: true,
      calories: 450,
      protein: 28,
      carbs: 38,
      fat: 20,
    ),
    'salad': FoodNutritionInfo(
      keywords: ['salad', 'green salad', 'broccoli', 'spinach', 'vegetables'],
      defaultServing: '1 bowl (100g)',
      defaultGrams: 100,
      isUnitBased: false,
      calories: 35,
      protein: 2.5,
      carbs: 6,
      fat: 0.4,
    ),
    'coffee': FoodNutritionInfo(
      keywords: ['coffee', 'black coffee', 'espresso', 'iced americano'],
      defaultServing: '1 cup',
      defaultGrams: 200,
      isUnitBased: true,
      calories: 5,
      protein: 0.3,
      carbs: 0.5,
      fat: 0,
    ),
    'latte': FoodNutritionInfo(
      keywords: ['latte', 'cappuccino', 'iced latte', 'flat white'],
      defaultServing: '1 cup (300ml)',
      defaultGrams: 300,
      isUnitBased: true,
      calories: 140,
      protein: 7,
      carbs: 12,
      fat: 6,
    ),
  };

  static List<FoodItem> estimateFromText(String text) {
    if (text.trim().isEmpty) return [];

    final clauses = text
        .split(RegExp(r',|\band\b|\bplus\b|\+|\&|\n', caseSensitive: false))
        .map((s) => s.trim())
        .filter((s) => s.isNotEmpty)
        .toList();

    final List<FoodItem> items = [];

    for (final clause in clauses) {
      final item = _parseClause(clause);
      if (item != null) {
        items.add(item);
      }
    }

    if (items.isEmpty) {
      final title = text.trim();
      items.add(
        FoodItem(
          id: _uuid.v4(),
          name: title.length > 30 ? title.substring(0, 30) : title,
          quantityText: '1 serving',
          calories: 350,
          protein: 20,
          carbs: 40,
          fat: 12,
          isAiEstimated: true,
        ),
      );
    }

    return items;
  }

  static FoodItem? _parseClause(String clause) {
    final lower = clause.toLowerCase();

    double multiplier = 1.0;
    String quantityText = '1 serving';

    final gramMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g|grams?)\b').firstMatch(lower);
    final cupMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:cups?|bowl|bowls?)\b').firstMatch(lower);
    final sliceMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:slices?|pieces?|scoops?|tbsp)\b').firstMatch(lower);
    final numMatch = RegExp(r'^(\d+(?:\.\d+)?)\s+').firstMatch(lower);

    double grams = 0;

    if (gramMatch != null) {
      grams = double.tryParse(gramMatch.group(1)!) ?? 0;
      quantityText = '${grams.toInt()}g';
    } else if (cupMatch != null) {
      multiplier = double.tryParse(cupMatch.group(1)!) ?? 1.0;
      quantityText = '$multiplier cup';
    } else if (sliceMatch != null) {
      multiplier = double.tryParse(sliceMatch.group(1)!) ?? 1.0;
      quantityText = '$multiplier item';
    } else if (numMatch != null) {
      multiplier = double.tryParse(numMatch.group(1)!) ?? 1.0;
      quantityText = '${multiplier.toInt()} items';
    }

    String? bestKey;
    String bestKeyword = '';

    for (final entry in _database.entries) {
      for (final kw in entry.value.keywords) {
        if (lower.contains(kw)) {
          if (bestKeyword.isEmpty || kw.length > bestKeyword.length) {
            bestKey = entry.key;
            bestKeyword = kw;
          }
        }
      }
    }

    if (bestKey == null) {
      final cleanName = clause.replaceAll(RegExp(r'^\d+\s*'), '').trim();
      if (cleanName.isEmpty) return null;
      return FoodItem(
        id: _uuid.v4(),
        name: cleanName[0].toUpperCase() + cleanName.substring(1),
        quantityText: quantityText,
        calories: 250 * multiplier,
        protein: 15 * multiplier,
        carbs: 25 * multiplier,
        fat: 8 * multiplier,
        isAiEstimated: true,
      );
    }

    final food = _database[bestKey]!;
    double factor = 1.0;

    if (grams > 0) {
      factor = grams / 100.0;
    } else if (food.isUnitBased) {
      factor = multiplier;
    } else {
      factor = (food.defaultGrams / 100.0) * multiplier;
    }

    final rawName = clause
        .replaceAll(RegExp(r'^\d+(?:\.\d+)?\s*(?:g|grams?|cups?|slices?|scoops?|pieces?)?\s*(?:of)?\s*', caseSensitive: false), '')
        .trim();

    final displayName = rawName.isNotEmpty ? rawName[0].toUpperCase() + rawName.substring(1) : bestKeyword;

    return FoodItem(
      id: _uuid.v4(),
      name: displayName,
      quantityText: quantityText != '1 serving' ? quantityText : food.defaultServing,
      calories: (food.calories * factor).roundToDouble(),
      protein: (food.protein * factor).roundToDouble(),
      carbs: (food.carbs * factor).roundToDouble(),
      fat: (food.fat * factor).roundToDouble(),
      isAiEstimated: true,
    );
  }
}

extension _ListFilter<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T) test) => where(test);
}
