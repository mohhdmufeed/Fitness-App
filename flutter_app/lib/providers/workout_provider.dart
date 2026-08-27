import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../services/exercise_catalog.dart';
import '../services/offline_storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  List<DailyWorkout> _workouts = [];
  List<WorkoutTemplate> _templates = [];
  DailyWorkout? _activeWorkout;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<DailyWorkout> get workouts => _workouts;
  List<WorkoutTemplate> get templates => _templates;
  DailyWorkout? get activeWorkout => _activeWorkout;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  String get selectedDateIso => DateFormat('yyyy-MM-dd').format(_selectedDate);

  WorkoutProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _workouts = await OfflineStorageService.loadWorkouts();
    _templates = await OfflineStorageService.loadTemplates();

    if (_templates.isEmpty) {
      _templates = ExerciseCatalog.getDefaultTemplates();
      await OfflineStorageService.saveTemplates(_templates);
    }

    _refreshActiveWorkout();
    _isLoading = false;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _refreshActiveWorkout();
    notifyListeners();
  }

  void _refreshActiveWorkout() {
    final iso = selectedDateIso;
    final existing = _workouts.where((w) => w.dateIso == iso).firstOrNull;
    if (existing != null) {
      _activeWorkout = existing;
    } else {
      _activeWorkout = DailyWorkout(
        id: _uuid.v4(),
        dateIso: iso,
        title: 'Daily Workout',
      );
    }
  }

  Future<void> addExerciseToActiveWorkout(Exercise baseExercise) async {
    if (_activeWorkout == null) return;

    final newExercise = baseExercise.copyWith(
      id: _uuid.v4(),
      sets: [
        ExerciseSet(id: _uuid.v4(), weight: 135, reps: 10, isCompleted: false),
        ExerciseSet(id: _uuid.v4(), weight: 135, reps: 10, isCompleted: false),
        ExerciseSet(id: _uuid.v4(), weight: 135, reps: 10, isCompleted: false),
      ],
    );

    _activeWorkout!.exercises.add(newExercise);
    await _saveCurrentWorkout();
    notifyListeners();
  }

  Future<void> removeExerciseFromActiveWorkout(int index) async {
    if (_activeWorkout == null || index < 0 || index >= _activeWorkout!.exercises.length) return;
    _activeWorkout!.exercises.removeAt(index);
    await _saveCurrentWorkout();
    notifyListeners();
  }

  Future<void> addSetToExercise(int exerciseIndex) async {
    if (_activeWorkout == null || exerciseIndex >= _activeWorkout!.exercises.length) return;
    final exercise = _activeWorkout!.exercises[exerciseIndex];
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;

    exercise.sets.add(
      ExerciseSet(
        id: _uuid.v4(),
        weight: lastSet?.weight ?? 135,
        reps: lastSet?.reps ?? 10,
        isCompleted: false,
      ),
    );

    await _saveCurrentWorkout();
    notifyListeners();
  }

  Future<void> removeSetFromExercise(int exerciseIndex, int setIndex) async {
    if (_activeWorkout == null || exerciseIndex >= _activeWorkout!.exercises.length) return;
    final exercise = _activeWorkout!.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    exercise.sets.removeAt(setIndex);
    await _saveCurrentWorkout();
    notifyListeners();
  }

  Future<void> updateSet(
    int exerciseIndex,
    int setIndex, {
    double? weight,
    int? reps,
    bool? isCompleted,
  }) async {
    if (_activeWorkout == null || exerciseIndex >= _activeWorkout!.exercises.length) return;
    final exercise = _activeWorkout!.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final targetSet = exercise.sets[setIndex];
    targetSet.weight = weight ?? targetSet.weight;
    targetSet.reps = reps ?? targetSet.reps;
    targetSet.isCompleted = isCompleted ?? targetSet.isCompleted;

    await _saveCurrentWorkout();
    notifyListeners();
  }

  Future<void> applyTemplate(WorkoutTemplate template) async {
    if (_activeWorkout == null) return;

    for (final exercise in template.exercises) {
      final copy = exercise.copyWith(
        id: _uuid.v4(),
        sets: [
          ExerciseSet(id: _uuid.v4(), weight: 135, reps: 10, isCompleted: false),
          ExerciseSet(id: _uuid.v4(), weight: 135, reps: 10, isCompleted: false),
          ExerciseSet(id: _uuid.v4(), weight: 135, reps: 10, isCompleted: false),
        ],
      );
      _activeWorkout!.exercises.add(copy);
    }

    _activeWorkout!.title = template.name;
    await _saveCurrentWorkout();
    notifyListeners();
  }

  Future<void> finishWorkout() async {
    if (_activeWorkout == null) return;
    _activeWorkout!.isCompleted = true;
    await _saveCurrentWorkout();
    notifyListeners();
  }

  Future<void> _saveCurrentWorkout() async {
    if (_activeWorkout == null) return;
    final index = _workouts.indexWhere((w) => w.dateIso == _activeWorkout!.dateIso);
    if (index >= 0) {
      _workouts[index] = _activeWorkout!;
    } else {
      _workouts.add(_activeWorkout!);
    }
    await OfflineStorageService.saveWorkouts(_workouts);
  }
}
