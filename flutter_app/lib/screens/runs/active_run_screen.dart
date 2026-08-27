import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/run_provider.dart';
import '../../theme/app_colors.dart';

class ActiveRunScreen extends StatelessWidget {
  const ActiveRunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          runProvider.isPaused ? 'PAUSED' : 'LIVE GPS RUN',
                          style: const TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 12,
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

              // Distance Hero Display
              Column(
                children: [
                  Text(
                    runProvider.currentDistanceMiles.toStringAsFixed(2),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  const Text(
                    'MILES',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Metrics Grid (Pace, Time, Calories)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric('PACE', runProvider.formattedPace, '/mi'),
                    Container(height: 36, width: 1, color: AppColors.divider),
                    _buildMetric('TIME', runProvider.formattedDuration, ''),
                    Container(height: 36, width: 1, color: AppColors.divider),
                    _buildMetric('CALORIES', '${runProvider.currentCaloriesBurned}', 'kcal'),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Action Buttons Row
              Row(
                children: [
                  // Pause / Resume Button
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: runProvider.isPaused ? AppColors.accentGreen : AppColors.cardSurface,
                        foregroundColor: runProvider.isPaused ? Colors.black : AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.cardBorder),
                        ),
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
                  // Finish & Save Button
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                content: Text('🏃 Awesome run! ${record.distanceMiles.toStringAsFixed(2)} mi recorded.'),
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
              const SizedBox(height: 20),
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
                fontSize: 22,
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
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
