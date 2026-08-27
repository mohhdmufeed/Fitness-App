enum WeightUnit { lbs, kg }

class WeightEntry {
  final String id;
  final String dateIso;
  final double weight;
  final String note;

  WeightEntry({
    required this.id,
    required this.dateIso,
    required this.weight,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'weight': weight,
        'note': note,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        id: json['id'] as String,
        dateIso: json['dateIso'] as String,
        weight: (json['weight'] as num).toDouble(),
        note: json['note'] as String? ?? '',
      );
}

class UserProfile {
  final String id;
  String name;
  String email;
  double targetCalories;
  double targetProtein;
  double targetCarbs;
  double targetFat;
  int targetWorkoutsPerWeek;
  int targetDailySteps;
  double? targetWeight;
  WeightUnit weightUnit;
  bool isGuest;

  UserProfile({
    required this.id,
    this.name = 'Athlete',
    this.email = 'athlete@kineticfusion.com',
    this.targetCalories = 2400.0,
    this.targetProtein = 180.0,
    this.targetCarbs = 250.0,
    this.targetFat = 70.0,
    this.targetWorkoutsPerWeek = 5,
    this.targetDailySteps = 10000,
    this.targetWeight = 175.0,
    this.weightUnit = WeightUnit.lbs,
    this.isGuest = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'targetCalories': targetCalories,
        'targetProtein': targetProtein,
        'targetCarbs': targetCarbs,
        'targetFat': targetFat,
        'targetWorkoutsPerWeek': targetWorkoutsPerWeek,
        'targetDailySteps': targetDailySteps,
        'targetWeight': targetWeight,
        'weightUnit': weightUnit.index,
        'isGuest': isGuest,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Athlete',
        email: json['email'] as String? ?? 'athlete@kineticfusion.com',
        targetCalories: (json['targetCalories'] as num?)?.toDouble() ?? 2400.0,
        targetProtein: (json['targetProtein'] as num?)?.toDouble() ?? 180.0,
        targetCarbs: (json['targetCarbs'] as num?)?.toDouble() ?? 250.0,
        targetFat: (json['targetFat'] as num?)?.toDouble() ?? 70.0,
        targetWorkoutsPerWeek: json['targetWorkoutsPerWeek'] as int? ?? 5,
        targetDailySteps: json['targetDailySteps'] as int? ?? 10000,
        targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 175.0,
        weightUnit: WeightUnit.values[json['weightUnit'] as int? ?? 0],
        isGuest: json['isGuest'] as bool? ?? true,
      );
}
