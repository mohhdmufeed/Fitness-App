import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/run_record.dart';
import '../../providers/run_provider.dart';
import '../../theme/app_colors.dart';
import 'active_run_screen.dart';

class RunsScreen extends StatelessWidget {
  const RunsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final runs = runProvider.runs;

    final totalMiles = runs.fold(0.0, (acc, r) => acc + r.distanceMiles);
    final totalRuns = runs.length;
    final totalCalories = runs.fold(0, (acc, r) => acc + r.caloriesBurned);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.directions_run_rounded, color: AppColors.accentGreen, size: 22),
            SizedBox(width: 10),
            Text('RUNS & CARDIO'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Total Runs Overview Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('TOTAL DISTANCE', '${totalMiles.toStringAsFixed(1)} mi'),
                Container(height: 28, width: 1, color: AppColors.divider),
                _buildStat('ACTIVITIES', '$totalRuns'),
                Container(height: 28, width: 1, color: AppColors.divider),
                _buildStat('CALORIES', '$totalCalories kcal'),
              ],
            ),
          ),

          // Dual Launch Cards: Outdoor (GPS) & Treadmill (Step Sensor)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Outdoor Run (GPS)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.location_on_rounded, size: 20),
                    label: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('OUTDOOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        Text('GPS Tracked', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    onPressed: () {
                      runProvider.startOutdoorRun();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ActiveRunScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Treadmill Run (Step Sensor)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardBackground,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.directions_walk_rounded, color: AppColors.accentTeal, size: 20),
                    label: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TREADMILL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        Text('Step Sensor', style: TextStyle(color: AppColors.accentTeal, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    onPressed: () {
                      runProvider.startTreadmillRun();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ActiveRunScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Run History Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RECENT ACTIVITIES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Runs History List
          Expanded(
            child: runs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_run_rounded, color: AppColors.textMuted, size: 48),
                        SizedBox(height: 10),
                        Text(
                          'No run sessions recorded yet.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select "OUTDOOR" or "TREADMILL" above',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: runs.length,
                    itemBuilder: (context, index) {
                      final run = runs[index];
                      final isTreadmill = run.runType == RunType.treadmill;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isTreadmill
                                      ? AppColors.accentTeal.withValues(alpha: 0.12)
                                      : AppColors.accentGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isTreadmill ? Icons.directions_walk_rounded : Icons.location_on_rounded,
                                  color: isTreadmill ? AppColors.accentTeal : AppColors.accentGreen,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${run.distanceMiles.toStringAsFixed(2)} mi',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isTreadmill
                                                ? AppColors.accentTeal.withValues(alpha: 0.2)
                                                : AppColors.accentGreen.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isTreadmill ? 'TREADMILL' : 'GPS',
                                            style: TextStyle(
                                              color: isTreadmill ? AppColors.accentTeal : AppColors.accentGreen,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        if (run.isPersonalRecord) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentYellow.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'PR',
                                              style: TextStyle(
                                                color: AppColors.accentYellow,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isTreadmill && run.stepsCount > 0
                                          ? '${run.dateIso} · ${run.stepsCount} steps'
                                          : run.dateIso,
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    run.formattedPace,
                                    style: const TextStyle(
                                      color: AppColors.accentGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    run.formattedDuration,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
