import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/run_record.dart';
import '../services/offline_storage_service.dart';

class RunProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  List<RunRecord> _runs = [];
  bool _isLoading = false;

  // Active Run State
  bool _isTracking = false;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  double _currentDistanceMiles = 0.0;
  Timer? _timer;

  List<RunRecord> get runs => _runs;
  bool get isLoading => _isLoading;
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  int get elapsedSeconds => _elapsedSeconds;
  double get currentDistanceMiles => _currentDistanceMiles;

  double get currentPaceSecondsPerMile {
    if (_currentDistanceMiles <= 0) return 0;
    return _elapsedSeconds / _currentDistanceMiles;
  }

  int get currentCaloriesBurned => (_currentDistanceMiles * 110).round();

  String get formattedPace {
    if (_currentDistanceMiles <= 0 || _elapsedSeconds <= 0) return "0'00\"";
    final totalSec = currentPaceSecondsPerMile.toInt();
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;
    return "$mins'${secs.toString().padLeft(2, '0')}\"";
  }

  String get formattedDuration {
    final mins = _elapsedSeconds ~/ 60;
    final secs = _elapsedSeconds % 60;
    if (mins >= 60) {
      final hours = mins ~/ 60;
      final remMins = mins % 60;
      return "${hours.toString().padLeft(2, '0')}:${remMins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
    }
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  RunProvider() {
    loadRuns();
  }

  Future<void> loadRuns() async {
    _isLoading = true;
    notifyListeners();
    _runs = await OfflineStorageService.loadRuns();
    _isLoading = false;
    notifyListeners();
  }

  void startRun() {
    _isTracking = true;
    _isPaused = false;
    _elapsedSeconds = 0;
    _currentDistanceMiles = 0.0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused) {
        _elapsedSeconds++;
        // Steady simulation / progression if GPS inactive indoors
        _currentDistanceMiles += 0.0022; // ~8 min mile pace increment
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  Future<RunRecord?> stopAndSaveRun() async {
    _timer?.cancel();
    _timer = null;

    if (_elapsedSeconds < 5 && _currentDistanceMiles < 0.05) {
      _isTracking = false;
      notifyListeners();
      return null;
    }

    final newRun = RunRecord(
      id: _uuid.v4(),
      dateIso: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      distanceMiles: _currentDistanceMiles,
      durationSeconds: _elapsedSeconds,
      averagePaceSecondsPerMile: currentPaceSecondsPerMile,
      caloriesBurned: currentCaloriesBurned,
      isPersonalRecord: _runs.isEmpty ||
          _runs.every((r) => r.distanceMiles < _currentDistanceMiles),
    );

    _runs.insert(0, newRun);
    await OfflineStorageService.saveRuns(_runs);

    _isTracking = false;
    _isPaused = false;
    _elapsedSeconds = 0;
    _currentDistanceMiles = 0.0;

    notifyListeners();
    return newRun;
  }

  void discardRun() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _isPaused = false;
    _elapsedSeconds = 0;
    _currentDistanceMiles = 0.0;
    notifyListeners();
  }
}
