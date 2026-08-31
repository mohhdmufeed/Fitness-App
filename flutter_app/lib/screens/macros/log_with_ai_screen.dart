import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal.dart';
import '../../providers/macro_provider.dart';
import '../../theme/app_colors.dart';

class LogWithAiScreen extends StatefulWidget {
  final MealType initialMealType;

  const LogWithAiScreen({
    super.key,
    this.initialMealType = MealType.breakfast,
  });

  @override
  State<LogWithAiScreen> createState() => _LogWithAiScreenState();
}

class _LogWithAiScreenState extends State<LogWithAiScreen> {
  final _inputController = TextEditingController();
  late MealType _selectedMealType;
  List<FoodItem>? _estimatedItems;
  bool _isEstimating = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _runAiEstimation() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isEstimating = true);

    // Instant on-device local estimation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final items = context.read<MacroProvider>().estimateMacrosFromText(text);
      if (!mounted) return;
      setState(() {
        _estimatedItems = items;
        _isEstimating = false;
      });
    });
  }

  void _logEstimatedFoods() {
    if (_estimatedItems == null || _estimatedItems!.isEmpty) return;

    context.read<MacroProvider>().addMultipleFoodItems(_selectedMealType, _estimatedItems!);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Logged ${_estimatedItems!.length} food items into ${_selectedMealType.name.toUpperCase()}'),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _estimatedItems?.fold(0.0, (acc, i) => acc + i.calories) ?? 0.0;
    final totalProtein = _estimatedItems?.fold(0.0, (acc, i) => acc + i.protein) ?? 0.0;
    final totalCarbs = _estimatedItems?.fold(0.0, (acc, i) => acc + i.carbs) ?? 0.0;
    final totalFat = _estimatedItems?.fold(0.0, (acc, i) => acc + i.fat) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.accentTeal, size: 20),
            SizedBox(width: 8),
            Text('LOG WITH AI'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal Target Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: MealType.values.map((type) {
                  final isSelected = _selectedMealType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMealType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          type.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // AI Natural Language Input Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_rounded, color: AppColors.accentGreen, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Describe what you ate',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inputController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. 2 whole eggs, 2 slices whole wheat toast with butter, and a scoop of whey protein in almond milk',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.cardSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quick Suggestions
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildChip('2 eggs & toast'),
                      _buildChip('Chicken breast 200g & rice'),
                      _buildChip('Whey protein & banana'),
                      _buildChip('Salmon, baked potato & salad'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Estimate Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentTeal,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isEstimating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                _isEstimating ? 'ESTIMATING WITH ON-DEVICE AI...' : 'ESTIMATE MACROS (OFFLINE AI)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: _isEstimating ? null : _runAiEstimation,
            ),
            const SizedBox(height: 24),

            // Results Section
            if (_estimatedItems != null && _estimatedItems!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cardBackground,
                      AppColors.cardSurface,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI NUTRITION BREAKDOWN',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${totalCalories.toInt()} KCAL',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Macro Summary Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroBadge('PROTEIN', '${totalProtein.toInt()}g', AppColors.accentCyan),
                        _buildMacroBadge('CARBS', '${totalCarbs.toInt()}g', AppColors.accentYellow),
                        _buildMacroBadge('FAT', '${totalFat.toInt()}g', AppColors.accentRed),
                      ],
                    ),
                    const Divider(height: 24),
                    // Itemized breakdown
                    ..._estimatedItems!.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '${item.calories.toInt()} kcal (${item.protein.toInt()}P/${item.carbs.toInt()}C/${item.fat.toInt()}F)',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Add to Log Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add_task_rounded),
                label: Text(
                  'LOG ${_estimatedItems!.length} ITEMS TO ${_selectedMealType.name.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: _logEstimatedFoods,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return ActionChip(
      backgroundColor: AppColors.cardSurface,
      label: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      onPressed: () {
        _inputController.text = text;
        _runAiEstimation();
      },
    );
  }

  Widget _buildMacroBadge(String title, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
