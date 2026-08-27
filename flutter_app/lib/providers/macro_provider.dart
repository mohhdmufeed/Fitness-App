import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal.dart';
import '../services/offline_ai_estimator.dart';
import '../services/offline_storage_service.dart';

class MacroProvider extends ChangeNotifier {
  List<Meal> _meals = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<Meal> get meals => _meals;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  String get selectedDateIso => DateFormat('yyyy-MM-dd').format(_selectedDate);

  double get totalCalories => _meals.fold(0.0, (acc, m) => acc + m.totalCalories);
  double get totalProtein => _meals.fold(0.0, (acc, m) => acc + m.totalProtein);
  double get totalCarbs => _meals.fold(0.0, (acc, m) => acc + m.totalCarbs);
  double get totalFat => _meals.fold(0.0, (acc, m) => acc + m.totalFat);

  MacroProvider() {
    loadMeals();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    loadMeals();
  }

  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();

    _meals = await OfflineStorageService.loadMealsForDate(selectedDateIso);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFoodItem(MealType type, FoodItem item) async {
    final mealIndex = _meals.indexWhere((m) => m.type == type);
    if (mealIndex >= 0) {
      _meals[mealIndex].items.add(item);
    } else {
      _meals.add(
        Meal(
          id: '${type.name}_$selectedDateIso',
          type: type,
          name: type.name[0].toUpperCase() + type.name.substring(1),
          items: [item],
        ),
      );
    }

    await OfflineStorageService.saveMealsForDate(selectedDateIso, _meals);
    notifyListeners();
  }

  Future<void> addMultipleFoodItems(MealType type, List<FoodItem> items) async {
    final mealIndex = _meals.indexWhere((m) => m.type == type);
    if (mealIndex >= 0) {
      _meals[mealIndex].items.addAll(items);
    } else {
      _meals.add(
        Meal(
          id: '${type.name}_$selectedDateIso',
          type: type,
          name: type.name[0].toUpperCase() + type.name.substring(1),
          items: items,
        ),
      );
    }

    await OfflineStorageService.saveMealsForDate(selectedDateIso, _meals);
    notifyListeners();
  }

  Future<void> removeFoodItem(MealType type, String itemId) async {
    final mealIndex = _meals.indexWhere((m) => m.type == type);
    if (mealIndex >= 0) {
      _meals[mealIndex].items.removeWhere((item) => item.id == itemId);
      await OfflineStorageService.saveMealsForDate(selectedDateIso, _meals);
      notifyListeners();
    }
  }

  List<FoodItem> estimateMacrosFromText(String naturalLanguageText) {
    return OfflineAiEstimator.estimateFromText(naturalLanguageText);
  }
}
