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
        title: const Text('RUNS & CARDIO'),
      ),
      body: Column(
        children: [
          // Total Runs Overview Banner (32px Rounded White Surface)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('TOTAL DISTANCE', '${totalMiles.toStringAsFixed(1)} mi'),
                Container(height: 28, width: 1, color: AppColors.cardBorder),
                _buildStat('ACTIVITIES', '$totalRuns'),
                Container(height: 28, width: 1, color: AppColors.cardBorder),
                _buildStat('CALORIES', '$totalCalories kcal'),
              ],
            ),
          ),

          // Dual Launch Cards: Outdoor (GPS) & Treadmill (Step Sensor)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Outdoor Run (GPS) - Pastel Red CTA
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCTA,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.location_on_rounded, size: 20),
                    label: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('OUTDOOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
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
                // Treadmill Run (Step Sensor) - White with Border
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.cardBackground,
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.borderSecondary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
                    ),
                    icon: const Icon(Icons.directions_walk_rounded, color: AppColors.accentTeal, size: 20),
                    label: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TREADMILL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                        Text('Phone Sensor', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 16),

          // Cardio Activity History List
          Expanded(
            child: runs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cardBackground,
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(
                            Icons.directions_run_rounded,
                            size: 36,
                            color: AppColors.primaryCTA,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No cardio activities yet',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Start an Outdoor Run or Treadmill session above.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: runs.length,
                    itemBuilder: (context, index) {
                      final run = runs[index];
                      return _buildRunCard(run);
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
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildRunCard(RunRecord run) {
    final isGps = run.runType == RunType.outdoor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isGps ? Icons.location_on_rounded : Icons.directions_walk_rounded,
              color: isGps ? AppColors.primaryCTA : AppColors.accentTeal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGps ? 'Outdoor GPS Run' : 'Indoor Treadmill Run',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${run.dateIso} • ${run.formattedDuration}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${run.distanceMiles.toStringAsFixed(2)} mi',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${run.caloriesBurned} kcal',
                style: const TextStyle(
                  color: AppColors.primaryCTA,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
