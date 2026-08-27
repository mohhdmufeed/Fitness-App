import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/offline_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile _user = UserProfile(id: 'athlete_1');
  bool _isAuthenticated = false;
  bool _isLoading = true;

  UserProfile get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    initAuth();
  }

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    _user = await OfflineStorageService.loadProfile();
    // Default to authenticated in offline first mode
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginOffline({String? email}) async {
    _user = UserProfile(
      id: 'athlete_offline',
      name: email != null && email.contains('@')
          ? email.split('@').first
          : 'Athlete',
      email: email ?? 'athlete@kineticfusion.com',
      isGuest: true,
    );
    await OfflineStorageService.saveProfile(_user);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    WeightUnit? weightUnit,
  }) async {
    _user.name = name ?? _user.name;
    _user.targetCalories = targetCalories ?? _user.targetCalories;
    _user.targetProtein = targetProtein ?? _user.targetProtein;
    _user.targetCarbs = targetCarbs ?? _user.targetCarbs;
    _user.targetFat = targetFat ?? _user.targetFat;
    _user.weightUnit = weightUnit ?? _user.weightUnit;

    await OfflineStorageService.saveProfile(_user);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = UserProfile(id: 'guest_athlete');
    await OfflineStorageService.saveProfile(_user);
    _isAuthenticated = false;
    notifyListeners();
  }
}
