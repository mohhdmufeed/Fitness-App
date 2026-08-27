enum RunType { outdoor, treadmill }

class RunLocationPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final String timestampIso;

  RunLocationPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    required this.timestampIso,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'speed': speed,
        'timestampIso': timestampIso,
      };

  factory RunLocationPoint.fromJson(Map<String, dynamic> json) => RunLocationPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        altitude: (json['altitude'] as num?)?.toDouble(),
        speed: (json['speed'] as num?)?.toDouble(),
        timestampIso: json['timestampIso'] as String,
      );
}

class RunRecord {
  final String id;
  final String dateIso;
  final double distanceMiles;
  final int durationSeconds;
  final int caloriesBurned;
  final double averagePaceSeconds;
  final bool isPersonalRecord;
  final RunType runType;
  final int stepsCount;
  final List<RunLocationPoint> pathPoints;

  RunRecord({
    required this.id,
    required this.dateIso,
    required this.distanceMiles,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.averagePaceSeconds,
    this.isPersonalRecord = false,
    this.runType = RunType.outdoor,
    this.stepsCount = 0,
    this.pathPoints = const [],
  });

  String get formattedPace {
    if (distanceMiles <= 0 || durationSeconds <= 0) return "--:--";
    final paceTotalSecs = (durationSeconds / distanceMiles).round();
    final mins = paceTotalSecs ~/ 60;
    final secs = paceTotalSecs % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}/mi";
  }

  String get formattedDuration {
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    if (mins >= 60) {
      final hours = mins ~/ 60;
      final remMins = mins % 60;
      return "${hours}h ${remMins}m";
    }
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'distanceMiles': distanceMiles,
        'durationSeconds': durationSeconds,
        'caloriesBurned': caloriesBurned,
        'averagePaceSeconds': averagePaceSeconds,
        'isPersonalRecord': isPersonalRecord,
        'runType': runType.name,
        'stepsCount': stepsCount,
        'pathPoints': pathPoints.map((p) => p.toJson()).toList(),
      };

  factory RunRecord.fromJson(Map<String, dynamic> json) => RunRecord(
        id: json['id'] as String,
        dateIso: json['dateIso'] as String,
        distanceMiles: (json['distanceMiles'] as num).toDouble(),
        durationSeconds: json['durationSeconds'] as int,
        caloriesBurned: json['caloriesBurned'] as int,
        averagePaceSeconds: (json['averagePaceSeconds'] as num).toDouble(),
        isPersonalRecord: json['isPersonalRecord'] as bool? ?? false,
        runType: RunType.values.firstWhere(
          (t) => t.name == (json['runType'] as String?),
          orElse: () => RunType.outdoor,
        ),
        stepsCount: json['stepsCount'] as int? ?? 0,
        pathPoints: (json['pathPoints'] as List<dynamic>?)
                ?.map((p) => RunLocationPoint.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
