import 'exercise.dart';

class DailyWorkout {
  final String id;
  final String dateIso; // yyyy-MM-dd
  String title;
  bool isCompleted;
  int durationMinutes;
  List<Exercise> exercises;


  DailyWorkout({
    required this.id,
    required this.dateIso,
    this.title = 'Daily Workout',
    this.isCompleted = false,
    this.durationMinutes = 0,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'title': title,
        'isCompleted': isCompleted,
        'durationMinutes': durationMinutes,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory DailyWorkout.fromJson(Map<String, dynamic> json) => DailyWorkout(
        id: json['id'] as String,
        dateIso: json['dateIso'] as String,
        title: json['title'] as String? ?? 'Daily Workout',
        isCompleted: json['isCompleted'] as bool? ?? false,
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        exercises: (json['exercises'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class WorkoutTemplate {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;

  WorkoutTemplate({
    required this.id,
    required this.name,
    this.description = '',
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        exercises: (json['exercises'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
