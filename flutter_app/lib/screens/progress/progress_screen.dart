import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _showLogWeightDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        title: const Text(
          'LOG BODYWEIGHT',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'e.g. 75.5',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            suffixText: 'kg',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCTA,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
            ),
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                context.read<ProgressProvider>().logWeight(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final user = context.watch<AuthProvider>().user;
    final entries = progress.weightEntries;

    final latestWeight = progress.latestWeight ?? 75.0;
    final targetWeight = user.targetWeight ?? 72.0;
    final diff = latestWeight - targetWeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PROGRESS & STATS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryCTA),
            tooltip: 'Log Bodyweight',
            onPressed: () => _showLogWeightDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Weight Goal Overview Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT WEIGHT',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              latestWeight.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'kg',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TARGET WEIGHT',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${targetWeight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: AppColors.primaryCTA,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          diff > 0
                              ? '${diff.toStringAsFixed(1)} kg to lose'
                              : '${diff.abs().toStringAsFixed(1)} kg to gain',
                          style: TextStyle(
                            color: diff <= 0 ? AppColors.accentGreen : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Weight Progress Chart
                const Text(
                  'WEIGHT PROGRESS (KG)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: entries.length < 2
                      ? const Center(
                          child: Text(
                            'Log more weight entries to view progress graph.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: entries
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
                                    .toList(),
                                isCurved: true,
                                color: AppColors.primaryCTA,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primaryCTA.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Strength 1RM Analytics Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTIMATED 1RM STRENGTH (KG)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStrengthRow('Bench Press', '92.5 kg', '+2.5 kg this month'),
                const Divider(height: 16),
                _buildStrengthRow('Back Squat', '125.0 kg', '+5.0 kg this month'),
                const Divider(height: 16),
                _buildStrengthRow('Deadlift', '150.0 kg', '+7.5 kg this month'),
                const Divider(height: 16),
                _buildStrengthRow('Overhead Press', '60.0 kg', '+1.0 kg this month'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthRow(String lift, String weight, String change) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lift, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(change, style: const TextStyle(color: Color(0xFF528770), fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
        Text(
          weight,
          style: const TextStyle(color: AppColors.primaryCTA, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ],
    );
  }
}
