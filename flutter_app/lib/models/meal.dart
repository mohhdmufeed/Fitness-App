enum MealType { breakfast, lunch, dinner, snacks }

class FoodItem {
  final String id;
  final String name;
  final String quantityText;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final bool isAiEstimated;

  FoodItem({
    required this.id,
    required this.name,
    this.quantityText = '1 serving',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isAiEstimated = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantityText': quantityText,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'isAiEstimated': isAiEstimated,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String,
        name: json['name'] as String,
        quantityText: json['quantityText'] as String? ?? '1 serving',
        calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
        isAiEstimated: json['isAiEstimated'] as bool? ?? false,
      );
}

class Meal {
  final String id;
  final MealType type;
  final String name;
  final List<FoodItem> items;

  Meal({
    required this.id,
    required this.type,
    required this.name,
    List<FoodItem>? items,
  }) : items = items ?? [];

  double get totalCalories => items.fold(0.0, (acc, item) => acc + item.calories);
  double get totalProtein => items.fold(0.0, (acc, item) => acc + item.protein);
  double get totalCarbs => items.fold(0.0, (acc, item) => acc + item.carbs);
  double get totalFat => items.fold(0.0, (acc, item) => acc + item.fat);

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'name': name,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'] as String,
        type: MealType.values[json['type'] as int? ?? 0],
        name: json['name'] as String,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class MacroTotals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MacroTotals({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });
}
