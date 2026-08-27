import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class ExerciseCatalog {
  static const _uuid = Uuid();

  static List<Exercise> getDefaultExercises() {
    return [
      // Chest
      Exercise(id: _uuid.v4(), name: 'Barbell Bench Press', bodyPart: BodyPart.chest),
      Exercise(id: _uuid.v4(), name: 'Incline Dumbbell Press', bodyPart: BodyPart.chest),
      Exercise(id: _uuid.v4(), name: 'Cable Chest Fly', bodyPart: BodyPart.chest),
      Exercise(id: _uuid.v4(), name: 'Push-Ups', bodyPart: BodyPart.chest, type: ExerciseType.repsOnly),
      Exercise(id: _uuid.v4(), name: 'Dips', bodyPart: BodyPart.chest, type: ExerciseType.repsOnly),

      // Back
      Exercise(id: _uuid.v4(), name: 'Barbell Deadlift', bodyPart: BodyPart.back),
      Exercise(id: _uuid.v4(), name: 'Barbell Bent-Over Row', bodyPart: BodyPart.back),
      Exercise(id: _uuid.v4(), name: 'Lat Pulldown', bodyPart: BodyPart.back),
      Exercise(id: _uuid.v4(), name: 'Pull-Ups', bodyPart: BodyPart.back, type: ExerciseType.repsOnly),
      Exercise(id: _uuid.v4(), name: 'Seated Cable Row', bodyPart: BodyPart.back),

      // Legs
      Exercise(id: _uuid.v4(), name: 'Barbell Back Squat', bodyPart: BodyPart.legs),
      Exercise(id: _uuid.v4(), name: 'Leg Press', bodyPart: BodyPart.legs),
      Exercise(id: _uuid.v4(), name: 'Romanian Deadlift', bodyPart: BodyPart.legs),
      Exercise(id: _uuid.v4(), name: 'Leg Extension', bodyPart: BodyPart.legs),
      Exercise(id: _uuid.v4(), name: 'Hamstring Leg Curl', bodyPart: BodyPart.legs),
      Exercise(id: _uuid.v4(), name: 'Standing Calf Raise', bodyPart: BodyPart.legs),

      // Shoulders
      Exercise(id: _uuid.v4(), name: 'Overhead Barbell Press', bodyPart: BodyPart.shoulders),
      Exercise(id: _uuid.v4(), name: 'Dumbbell Lateral Raise', bodyPart: BodyPart.shoulders),
      Exercise(id: _uuid.v4(), name: 'Face Pulls', bodyPart: BodyPart.shoulders),
      Exercise(id: _uuid.v4(), name: 'Arnold Press', bodyPart: BodyPart.shoulders),

      // Arms
      Exercise(id: _uuid.v4(), name: 'Barbell Bicep Curl', bodyPart: BodyPart.arms),
      Exercise(id: _uuid.v4(), name: 'Dumbbell Hammer Curl', bodyPart: BodyPart.arms),
      Exercise(id: _uuid.v4(), name: 'Tricep Rope Pushdown', bodyPart: BodyPart.arms),
      Exercise(id: _uuid.v4(), name: 'Skull Crushers', bodyPart: BodyPart.arms),

      // Core
      Exercise(id: _uuid.v4(), name: 'Plank', bodyPart: BodyPart.core, type: ExerciseType.timeOnly),
      Exercise(id: _uuid.v4(), name: 'Hanging Leg Raise', bodyPart: BodyPart.core, type: ExerciseType.repsOnly),
      Exercise(id: _uuid.v4(), name: 'Cable Woodchopper', bodyPart: BodyPart.core),
      Exercise(id: _uuid.v4(), name: 'Ab Wheel Rollout', bodyPart: BodyPart.core, type: ExerciseType.repsOnly),
    ];
  }

  static List<WorkoutTemplate> getDefaultTemplates() {
    return [
      WorkoutTemplate(
        id: 'push_day',
        name: 'Push Day (Chest, Shoulders, Triceps)',
        description: 'Upper body pushing strength & hypertrophy focus',
        exercises: [
          Exercise(id: _uuid.v4(), name: 'Barbell Bench Press', bodyPart: BodyPart.chest),
          Exercise(id: _uuid.v4(), name: 'Overhead Barbell Press', bodyPart: BodyPart.shoulders),
          Exercise(id: _uuid.v4(), name: 'Incline Dumbbell Press', bodyPart: BodyPart.chest),
          Exercise(id: _uuid.v4(), name: 'Dumbbell Lateral Raise', bodyPart: BodyPart.shoulders),
          Exercise(id: _uuid.v4(), name: 'Tricep Rope Pushdown', bodyPart: BodyPart.arms),
        ],
      ),
      WorkoutTemplate(
        id: 'pull_day',
        name: 'Pull Day (Back & Biceps)',
        description: 'Upper body pulling strength & thickness focus',
        exercises: [
          Exercise(id: _uuid.v4(), name: 'Barbell Deadlift', bodyPart: BodyPart.back),
          Exercise(id: _uuid.v4(), name: 'Lat Pulldown', bodyPart: BodyPart.back),
          Exercise(id: _uuid.v4(), name: 'Barbell Bent-Over Row', bodyPart: BodyPart.back),
          Exercise(id: _uuid.v4(), name: 'Face Pulls', bodyPart: BodyPart.shoulders),
          Exercise(id: _uuid.v4(), name: 'Barbell Bicep Curl', bodyPart: BodyPart.arms),
        ],
      ),
      WorkoutTemplate(
        id: 'legs_core',
        name: 'Legs & Core',
        description: 'Lower body power, quads, hamstrings and abs',
        exercises: [
          Exercise(id: _uuid.v4(), name: 'Barbell Back Squat', bodyPart: BodyPart.legs),
          Exercise(id: _uuid.v4(), name: 'Romanian Deadlift', bodyPart: BodyPart.legs),
          Exercise(id: _uuid.v4(), name: 'Leg Press', bodyPart: BodyPart.legs),
          Exercise(id: _uuid.v4(), name: 'Standing Calf Raise', bodyPart: BodyPart.legs),
          Exercise(id: _uuid.v4(), name: 'Hanging Leg Raise', bodyPart: BodyPart.core, type: ExerciseType.repsOnly),
        ],
      ),
    ];
  }
}
