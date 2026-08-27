import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/run_record.dart';
import '../../providers/run_provider.dart';
import '../../theme/app_colors.dart';

class ActiveRunScreen extends StatelessWidget {
  const ActiveRunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final isTreadmill = runProvider.currentRunType == RunType.treadmill;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isTreadmill
                          ? AppColors.accentTeal.withValues(alpha: 0.15)
                          : AppColors.accentGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isTreadmill ? Icons.directions_walk_rounded : Icons.location_on_rounded,
                          color: isTreadmill ? AppColors.accentTeal : AppColors.accentGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          runProvider.isPaused
                              ? 'PAUSED'
                              : (isTreadmill ? 'TREADMILL (STEP SENSOR)' : 'LIVE GPS OUTDOOR'),
                          style: TextStyle(
                            color: isTreadmill ? AppColors.accentTeal : AppColors.accentGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () {
                      runProvider.discardRun();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Spacer(),

              // Primary Hero Display (Distance or Steps)
              Column(
                children: [
                  Text(
                    runProvider.currentDistanceMiles.toStringAsFixed(2),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 68,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  const Text(
                    'MILES',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  if (isTreadmill) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '👣 ${runProvider.currentSteps} STEPS',
                        style: const TextStyle(
                          color: AppColors.accentTeal,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),

              // Metrics Grid
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (isTreadmill)
                      _buildMetric('CADENCE', '${runProvider.currentCadence}', 'spm')
                    else
                      _buildMetric('PACE', runProvider.formattedPace, '/mi'),
                    Container(height: 36, width: 1, color: AppColors.divider),
                    _buildMetric('TIME', runProvider.formattedDuration, ''),
                    Container(height: 36, width: 1, color: AppColors.divider),
                    _buildMetric('CALORIES', '${runProvider.currentCaloriesBurned}', 'kcal'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons Row (Pause/Resume + Finish)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: runProvider.isPaused ? AppColors.accentGreen : AppColors.cardSurface,
                        foregroundColor: runProvider.isPaused ? Colors.black : AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(runProvider.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                      label: Text(
                        runProvider.isPaused ? 'RESUME' : 'PAUSE',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      onPressed: () => runProvider.togglePause(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'FINISH RUN',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      onPressed: () async {
                        final record = await runProvider.stopAndSaveRun();
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (record != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🏃 Session saved! ${record.distanceMiles.toStringAsFixed(2)} mi recorded.'),
                                backgroundColor: AppColors.accentGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, String unit) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
