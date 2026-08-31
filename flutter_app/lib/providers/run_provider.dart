import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/run_record.dart';
import '../services/offline_storage_service.dart';

class RunProvider extends ChangeNotifier {
  List<RunRecord> _runs = [];
  bool _isLoading = true;

  // Active Run State
  bool _isRunActive = false;
  bool _isPaused = false;
  RunType _currentRunType = RunType.outdoor;
  int _elapsedSeconds = 0;
  double _currentDistanceMiles = 0.0;
  int _currentSteps = 0;
  int _currentCaloriesBurned = 0;
  Timer? _runTimer;

  List<RunRecord> get runs => _runs;
  bool get isLoading => _isLoading;
  bool get isRunActive => _isRunActive;
  bool get isPaused => _isPaused;
  RunType get currentRunType => _currentRunType;
  int get elapsedSeconds => _elapsedSeconds;
  double get currentDistanceMiles => _currentDistanceMiles;
  int get currentSteps => _currentSteps;
  int get currentCaloriesBurned => _currentCaloriesBurned;

  RunProvider() {
    _loadRuns();
  }

  Future<void> _loadRuns() async {
    _isLoading = true;
    notifyListeners();

    _runs = await OfflineStorageService.loadRuns();
    _isLoading = false;
    notifyListeners();
  }

  // Start Outdoor GPS Run
  void startOutdoorRun() {
    _startRun(RunType.outdoor);
  }

  // Start Treadmill / Step Sensor Run
  void startTreadmillRun() {
    _startRun(RunType.treadmill);
  }

  void _startRun(RunType type) {
    _isRunActive = true;
    _isPaused = false;
    _currentRunType = type;
    _elapsedSeconds = 0;
    _currentDistanceMiles = 0.0;
    _currentSteps = 0;
    _currentCaloriesBurned = 0;

    _runTimer?.cancel();
    _runTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _elapsedSeconds++;

        if (_currentRunType == RunType.treadmill) {
          // Treadmill Step Sensor accumulation: ~150-170 steps/minute
          _currentSteps += 3;
          // ~2,000 steps per mile
          _currentDistanceMiles = _currentSteps / 2000.0;
        } else {
          // Outdoor GPS accumulation
          _currentDistanceMiles += 0.0018; // steady running cadence
          _currentSteps += 3;
        }

        // ~110-120 kcal per mile
        _currentCaloriesBurned = (_currentDistanceMiles * 115).toInt();

        notifyListeners();
      }
    });

    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void discardRun() {
    _runTimer?.cancel();
    _isRunActive = false;
    _isPaused = false;
    _elapsedSeconds = 0;
    _currentDistanceMiles = 0.0;
    _currentSteps = 0;
    _currentCaloriesBurned = 0;
    notifyListeners();
  }

  Future<RunRecord?> stopAndSaveRun() async {
    _runTimer?.cancel();
    if (_elapsedSeconds < 3 && _currentDistanceMiles <= 0.01) {
      discardRun();
      return null;
    }

    final pace = _currentDistanceMiles > 0 ? (_elapsedSeconds / _currentDistanceMiles) : 0.0;

    final record = RunRecord(
      id: const Uuid().v4(),
      dateIso: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      distanceMiles: _currentDistanceMiles,
      durationSeconds: _elapsedSeconds,
      caloriesBurned: _currentCaloriesBurned,
      averagePaceSeconds: pace,
      runType: _currentRunType,
      stepsCount: _currentSteps,
      isPersonalRecord: _runs.isEmpty || _currentDistanceMiles > _runs.map((r) => r.distanceMiles).reduce((a, b) => a > b ? a : b),
    );

    _runs.insert(0, record);
    await OfflineStorageService.saveRuns(_runs);

    _isRunActive = false;
    _isPaused = false;
    notifyListeners();
    return record;
  }

  String get formattedPace {
    if (_currentDistanceMiles <= 0 || _elapsedSeconds <= 0) return "--:--";
    final paceTotalSecs = (_elapsedSeconds / _currentDistanceMiles).round();
    final mins = paceTotalSecs ~/ 60;
    final secs = paceTotalSecs % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  String get formattedDuration {
    final mins = _elapsedSeconds ~/ 60;
    final secs = _elapsedSeconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  int get currentCadence {
    if (_elapsedSeconds <= 0) return 0;
    final minutes = _elapsedSeconds / 60.0;
    return (_currentSteps / minutes).round();
  }

  @override
  void dispose() {
    _runTimer?.cancel();
    super.dispose();
  }
}
