import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_colors.dart';
import 'add_exercise_screen.dart';
import 'templates_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final workout = workoutProvider.activeWorkout;
    final exercises = workout?.exercises ?? [];

    final completedSets = exercises.fold(
      0,
      (acc, e) => acc + e.sets.where((s) => s.isCompleted).length,
    );
    final totalSets = exercises.fold(0, (acc, e) => acc + e.sets.length);
    final totalVolume = exercises.fold(
      0.0,
      (acc, e) =>
          acc +
          e.sets
              .where((s) => s.isCompleted)
              .fold(0.0, (sAcc, s) => sAcc + (s.weight * s.reps)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('TRAIN & WORKOUTS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded, color: AppColors.primaryCTA),
            tooltip: 'Routines & Templates',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TemplatesScreen()),
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
                    workoutProvider.selectDate(
                      workoutProvider.selectedDate.subtract(const Duration(days: 1)),
                    );
                  },
                ),
                Text(
                  DateFormat('EEEE, MMM d').format(workoutProvider.selectedDate),
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
                    workoutProvider.selectDate(
                      workoutProvider.selectedDate.add(const Duration(days: 1)),
                    );
                  },
                ),
              ],
            ),
          ),

          // Workout Stats Overview Card (32px Rounded White Surface)
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
                _buildStatItem('EXERCISES', '${exercises.length}'),
                _buildDivider(),
                _buildStatItem('SETS LOGGED', '$completedSets / $totalSets'),
                _buildDivider(),
                _buildStatItem('VOLUME', '${totalVolume.toInt()} kg'),
              ],
            ),
          ),

          // Workout Content List
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              size: 40,
                              color: AppColors.primaryCTA,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'START WORKOUT',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Choose a routine and let's begin.",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryCTA,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(48),
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(
                              'ADD EXERCISE',
                              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: exercises.length,
                    itemBuilder: (context, exIndex) {
                      final exercise = exercises[exIndex];
                      return _buildExerciseCard(context, workoutProvider, exercise, exIndex);
                    },
                  ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.borderSecondary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
                    ),
                    icon: const Icon(Icons.add_rounded, color: AppColors.primaryCTA, size: 18),
                    label: const Text('ADD EXERCISE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
                      );
                    },
                  ),
                ),
                if (exercises.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: workout?.isCompleted == true
                            ? AppColors.accentGreen
                            : AppColors.primaryCTA,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
                      ),
                      icon: Icon(workout?.isCompleted == true
                          ? Icons.check_circle_rounded
                          : Icons.flag_rounded, size: 18),
                      label: Text(
                        workout?.isCompleted == true ? 'COMPLETED' : 'FINISH WORKOUT',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                      ),
                      onPressed: () {
                        workoutProvider.finishWorkout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🔥 Great workout! Workout recorded successfully.'),
                            backgroundColor: AppColors.accentGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    WorkoutProvider provider,
    Exercise exercise,
    int exIndex,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exercise.bodyPart.name.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 20),
                  onPressed: () => provider.removeExerciseFromActiveWorkout(exIndex),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Sets Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                SizedBox(
                  width: 32,
                  child: Text('SET', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Center(
                    child: Text('KG', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('REPS', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text('DONE', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // Sets List
          ...exercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final setLog = entry.value;
            return _buildSetRow(provider, exIndex, setIndex, setLog);
          }),

          // Add Set Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryCTA),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ Add Set', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => provider.addSetToExercise(exIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(WorkoutProvider provider, int exIndex, int setIndex, ExerciseSet setLog) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: setLog.isCompleted ? AppColors.accentGreen.withValues(alpha: 0.12) : Colors.transparent,
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('${setIndex + 1}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 70,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: setLog.weight > 0 ? '${setLog.weight}' : '0',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    final w = double.tryParse(val) ?? setLog.weight;
                    provider.updateSet(exIndex, setIndex, weight: w);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 70,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: setLog.reps > 0 ? '${setLog.reps}' : '0',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    final r = int.tryParse(val) ?? setLog.reps;
                    provider.updateSet(exIndex, setIndex, reps: r);
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              icon: Icon(
                setLog.isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: setLog.isCompleted ? const Color(0xFF43755F) : AppColors.textMuted,
              ),
              onPressed: () => provider.updateSet(exIndex, setIndex, isCompleted: !setLog.isCompleted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.cardBorder,
    );
  }
}
