import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.accentGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('TRAIN & WORKOUTS'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded, color: AppColors.accentTeal),
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
              border: Border(bottom: BorderSide(color: AppColors.divider)),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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

          // Workout Stats Overview
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cardBackground,
                  AppColors.cardSurface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('EXERCISES', '${exercises.length}'),
                _buildDivider(),
                _buildStatItem('SETS LOGGED', '$completedSets / $totalSets'),
                _buildDivider(),
                _buildStatItem('VOLUME', '${totalVolume.toInt()} lbs'),
              ],
            ),
          ),

          // Workout Content List
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fitness_center_rounded,
                          size: 54,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No exercises in today’s workout',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap "+ Add Exercise" or choose a routine',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'ADD EXERCISE',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_rounded, color: AppColors.accentGreen),
                    label: const Text('ADD EXERCISE', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            ? AppColors.accentTeal
                            : AppColors.accentGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(workout?.isCompleted == true
                          ? Icons.check_circle_rounded
                          : Icons.flag_rounded),
                      label: Text(
                        workout?.isCompleted == true ? 'COMPLETED' : 'FINISH WORKOUT',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildStatItem(String label, String value) {
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
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: AppColors.divider);
  }

  Widget _buildExerciseCard(
    BuildContext context,
    WorkoutProvider provider,
    dynamic exercise,
    int exIndex,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
                  onPressed: () => provider.removeExerciseFromActiveWorkout(exIndex),
                  tooltip: 'Remove exercise',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sets Table Header
            const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'SET',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'LBS',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'REPS',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'DONE',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sets List
            ...List.generate(exercise.sets.length, (setIndex) {
              final set = exercise.sets[setIndex];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: set.isCompleted
                      ? AppColors.accentGreen.withOpacity(0.08)
                      : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: set.isCompleted
                        ? AppColors.accentGreen.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${setIndex + 1}',
                        style: TextStyle(
                          color: set.isCompleted ? AppColors.accentGreen : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: '${set.weight.toInt()}',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null) {
                            provider.updateSet(exIndex, setIndex, weight: parsed);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: '${set.reps}',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null) {
                            provider.updateSet(exIndex, setIndex, reps: parsed);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: IconButton(
                        icon: Icon(
                          set.isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                          color: set.isCompleted ? AppColors.accentGreen : AppColors.textMuted,
                          size: 22,
                        ),
                        onPressed: () {
                          provider.updateSet(exIndex, setIndex, isCompleted: !set.isCompleted);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            // Add Set Button
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentTeal,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('+ Add Set', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => provider.addSetToExercise(exIndex),
            ),
          ],
        ),
      ),
    );
  }
}
