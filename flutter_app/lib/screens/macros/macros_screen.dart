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
        title: const Row(
          children: [
            Icon(Icons.pie_chart_rounded, color: AppColors.accentOrange, size: 20),
            SizedBox(width: 10),
            Text('MACROS & NUTRITION'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.accentTeal),
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
              border: Border(bottom: BorderSide(color: AppColors.divider)),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cardBackground,
                        AppColors.cardSurface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      // Calorie Circular Indicator
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: calorieProgress,
                              strokeWidth: 9,
                              backgroundColor: AppColors.cardBorder,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${currentCalories.toInt()}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Text(
                                    'KCAL',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Target & Remaining Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${remainingCalories.toInt()} KCAL LEFT',
                              style: const TextStyle(
                                color: AppColors.accentGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Target: ${targetCalories.toInt()} kcal',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            // Quick Log With AI Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentTeal.withOpacity(0.2),
                                  foregroundColor: AppColors.accentTeal,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                label: const Text(
                                  'LOG WITH AI',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LogWithAiScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Macros Breakdown Bars
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _buildMacroBar(
                        'PROTEIN',
                        macroProvider.totalProtein,
                        user.targetProtein,
                        AppColors.accentCyan,
                      ),
                      const SizedBox(height: 12),
                      _buildMacroBar(
                        'CARBS',
                        macroProvider.totalCarbs,
                        user.targetCarbs,
                        AppColors.accentYellow,
                      ),
                      const SizedBox(height: 12),
                      _buildMacroBar(
                        'FAT',
                        macroProvider.totalFat,
                        user.targetFat,
                        AppColors.accentRed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Meal Categories Section
                const Text(
                  'MEALS TODAY',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),

                ...MealType.values.map((type) {
                  final meal = macroProvider.meals.firstWhere(
                    (m) => m.type == type,
                    orElse: () => Meal(id: type.name, type: type, name: type.name),
                  );
                  return _buildMealCard(context, macroProvider, meal, type);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String name, double current, double target, Color color) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              '${current.toInt()} / ${target.toInt()}g',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.cardSurface,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(6),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, MacroProvider provider, Meal meal, MealType type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${meal.totalCalories.toInt()} kcal',
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.accentTeal, size: 20),
                      color: AppColors.cardBackground,
                      onSelected: (val) {
                        if (val == 'ai') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LogWithAiScreen(initialMealType: type)),
                          );
                        } else if (val == 'manual') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddFoodScreen(mealType: type)),
                          );
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'ai',
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: AppColors.accentTeal, size: 18),
                              SizedBox(width: 8),
                              Text('Log with AI (Offline)'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'manual',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, color: AppColors.accentGreen, size: 18),
                              SizedBox(width: 8),
                              Text('Manual Food Entry'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (meal.items.isNotEmpty) ...[
              const Divider(height: 16),
              ...meal.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name} (${item.quantityText})',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                      Text(
                        '${item.calories.toInt()} kcal',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => provider.removeFoodItem(type, item.id),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
