enum BodyPart { chest, back, legs, shoulders, arms, core, cardio, fullBody }

enum ExerciseType { weightAndReps, repsOnly, timeAndDistance, timeOnly }

class ExerciseSet {
  final String id;
  double weight;
  int reps;
  int durationSeconds;
  double distanceMiles;
  bool isCompleted;

  ExerciseSet({
    required this.id,
    this.weight = 0.0,
    this.reps = 0,
    this.durationSeconds = 0,
    this.distanceMiles = 0.0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight': weight,
        'reps': reps,
        'durationSeconds': durationSeconds,
        'distanceMiles': distanceMiles,
        'isCompleted': isCompleted,
      };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
        id: json['id'] as String,
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        reps: json['reps'] as int? ?? 0,
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        distanceMiles: (json['distanceMiles'] as num?)?.toDouble() ?? 0.0,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class Exercise {
  final String id;
  final String name;
  final BodyPart bodyPart;
  final ExerciseType type;
  List<ExerciseSet> sets;

  Exercise({
    required this.id,
    required this.name,
    this.bodyPart = BodyPart.fullBody,
    this.type = ExerciseType.weightAndReps,
    List<ExerciseSet>? sets,
  }) : sets = sets ?? [];

  Exercise copyWith({
    String? id,
    String? name,
    BodyPart? bodyPart,
    ExerciseType? type,
    List<ExerciseSet>? sets,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      type: type ?? this.type,
      sets: sets ?? this.sets.map((s) => ExerciseSet.fromJson(s.toJson())).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bodyPart': bodyPart.index,
        'type': type.index,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        bodyPart: BodyPart.values[json['bodyPart'] as int? ?? 0],
        type: ExerciseType.values[json['type'] as int? ?? 0],
        sets: (json['sets'] as List<dynamic>?)
                ?.map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
