import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/meal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/macro_provider.dart';
import '../../theme/app_colors.dart';
import 'add_food_screen.dart';
import 'log_with_ai_screen.dart';

class MacrosScreen extends StatelessWidget {
  const MacrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final macroProvider = context.watch<MacroProvider>();
    final user = context.watch<AuthProvider>().user;

    final targetCalories = user.targetCalories;
    final currentCalories = macroProvider.totalCalories;
    final remainingCalories = (targetCalories - currentCalories).clamp(0.0, 99999.0);
    final calorieProgress = targetCalories > 0 ? (currentCalories / targetCalories).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MACROS & NUTRITION'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryCTA),
            tooltip: 'Log with AI',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogWithAiScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                  onPressed: () {
                    macroProvider.selectDate(
                      macroProvider.selectedDate.subtract(const Duration(days: 1)),
                    );
                  },
                ),
                Text(
                  DateFormat('EEEE, MMM d').format(macroProvider.selectedDate),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onPressed: () {
                    macroProvider.selectDate(
                      macroProvider.selectedDate.add(const Duration(days: 1)),
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Calorie Target Card with Visual Circular Gauge
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: const [AppColors.cardShadow],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DAILY CALORIES',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currentCalories.toInt()}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '/ ${targetCalories.toInt()} kcal target',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 84,
                                height: 84,
                                child: CircularProgressIndicator(
                                  value: calorieProgress,
                                  strokeWidth: 8,
                                  backgroundColor: AppColors.background,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCTA),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${remainingCalories.toInt()}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Text(
                                    'left',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Macronutrient Breakdown Bars
                      Row(
                        children: [
                          Expanded(
                            child: _buildMacroBar(
                              label: 'PROTEIN',
                              current: macroProvider.totalProtein,
                              target: user.targetProtein,
                              color: AppColors.primaryCTA,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMacroBar(
                              label: 'CARBS',
                              current: macroProvider.totalCarbs,
                              target: user.targetCarbs,
                              color: AppColors.accentTeal,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMacroBar(
                              label: 'FAT',
                              current: macroProvider.totalFat,
                              target: user.targetFat,
                              color: AppColors.accentYellow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Meal Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MEAL LOG',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: AppColors.primaryCTA),
                      icon: const Icon(Icons.auto_awesome, size: 14),
                      label: const Text('AI Log', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LogWithAiScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                _buildMealCategoryCard(context, macroProvider, MealType.breakfast, 'Breakfast'),
                _buildMealCategoryCard(context, macroProvider, MealType.lunch, 'Lunch'),
                _buildMealCategoryCard(context, macroProvider, MealType.dinner, 'Dinner'),
                _buildMealCategoryCard(context, macroProvider, MealType.snacks, 'Snacks'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar({
    required String label,
    required double current,
    required double target,
    required Color color,
  }) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${current.toInt()}g',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '/ ${target.toInt()}g',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMealCategoryCard(
    BuildContext context,
    MacroProvider provider,
    MealType type,
    String title,
  ) {
    final meal = provider.meals.where((m) => m.type == type).firstOrNull;
    final foods = meal?.items ?? [];
    final totalCals = foods.fold(0.0, (acc, f) => acc + f.calories);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 14),
            ),
            subtitle: Text(
              '${totalCals.toInt()} kcal • ${foods.length} items',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryCTA),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddFoodScreen(mealType: type)),
                );
              },
            ),
          ),
          if (foods.isNotEmpty) ...[
            const Divider(height: 1),
            ...foods.map((food) => ListTile(
                  dense: true,
                  title: Text(food.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'P: ${food.protein.toInt()}g  C: ${food.carbs.toInt()}g  F: ${food.fat.toInt()}g',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${food.calories.toInt()} kcal',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.accentRed),
                        onPressed: () => provider.removeFoodItem(type, food.id),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
