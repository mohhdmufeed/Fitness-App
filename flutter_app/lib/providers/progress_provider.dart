import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../services/offline_storage_service.dart';

class ProgressProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  List<WeightEntry> _weightEntries = [];
  bool _isLoading = false;

  List<WeightEntry> get weightEntries => _weightEntries;
  bool get isLoading => _isLoading;

  double? get latestWeight =>
      _weightEntries.isNotEmpty ? _weightEntries.last.weight : null;

  ProgressProvider() {
    loadWeightEntries();
  }

  Future<void> loadWeightEntries() async {
    _isLoading = true;
    notifyListeners();

    _weightEntries = await OfflineStorageService.loadWeightEntries();
    if (_weightEntries.isEmpty) {
      // Seed default entry for realistic visual chart
      final now = DateTime.now();
      _weightEntries = [
        WeightEntry(
          id: _uuid.v4(),
          dateIso: DateFormat('yyyy-MM-dd')
              .format(now.subtract(const Duration(days: 14))),
          weight: 182.5,
        ),
        WeightEntry(
          id: _uuid.v4(),
          dateIso: DateFormat('yyyy-MM-dd')
              .format(now.subtract(const Duration(days: 7))),
          weight: 180.2,
        ),
        WeightEntry(
          id: _uuid.v4(),
          dateIso: DateFormat('yyyy-MM-dd').format(now),
          weight: 178.6,
        ),
      ];
      await OfflineStorageService.saveWeightEntries(_weightEntries);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logWeight(double weight, {String note = ''}) async {
    final entry = WeightEntry(
      id: _uuid.v4(),
      dateIso: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      weight: weight,
      note: note,
    );

    _weightEntries.add(entry);
    _weightEntries.sort((a, b) => a.dateIso.compareTo(b.dateIso));
    await OfflineStorageService.saveWeightEntries(_weightEntries);
    notifyListeners();
  }
}
