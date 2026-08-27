class RunLocationPoint {
  final double latitude;
  final double longitude;
  final int timestampMs;

  RunLocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestampMs': timestampMs,
      };

  factory RunLocationPoint.fromJson(Map<String, dynamic> json) =>
      RunLocationPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestampMs: json['timestampMs'] as int,
      );
}

class RunRecord {
  final String id;
  final String dateIso;
  final double distanceMiles;
  final int durationSeconds;
  final double averagePaceSecondsPerMile;
  final int caloriesBurned;
  final bool isPersonalRecord;
  final List<RunLocationPoint> route;

  RunRecord({
    required this.id,
    required this.dateIso,
    required this.distanceMiles,
    required this.durationSeconds,
    required this.averagePaceSecondsPerMile,
    required this.caloriesBurned,
    this.isPersonalRecord = false,
    List<RunLocationPoint>? route,
  }) : route = route ?? [];

  String get formattedPace {
    if (distanceMiles <= 0 || durationSeconds <= 0) return "0'00\"";
    final totalSec = averagePaceSecondsPerMile.toInt();
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;
    return "$mins'${secs.toString().padLeft(2, '0')}\"";
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
        'averagePaceSecondsPerMile': averagePaceSecondsPerMile,
        'caloriesBurned': caloriesBurned,
        'isPersonalRecord': isPersonalRecord,
        'route': route.map((p) => p.toJson()).toList(),
      };

  factory RunRecord.fromJson(Map<String, dynamic> json) => RunRecord(
        id: json['id'] as String,
        dateIso: json['dateIso'] as String,
        distanceMiles: (json['distanceMiles'] as num?)?.toDouble() ?? 0.0,
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        averagePaceSecondsPerMile:
            (json['averagePaceSecondsPerMile'] as num?)?.toDouble() ?? 0.0,
        caloriesBurned: json['caloriesBurned'] as int? ?? 0,
        isPersonalRecord: json['isPersonalRecord'] as bool? ?? false,
        route: (json['route'] as List<dynamic>?)
                ?.map((p) => RunLocationPoint.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
