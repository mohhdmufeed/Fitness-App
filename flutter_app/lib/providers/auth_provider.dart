import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/offline_storage_service.dart';
import '../services/secure_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile _user = UserProfile.defaultProfile();
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _isOnline = true;

  UserProfile get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    _isOnline = await SecureAuthService.hasInternet();
    _user = await OfflineStorageService.loadProfile();
    _isAuthenticated = await SecureAuthService.isUserSessionActive();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshConnectivity() async {
    _isOnline = await SecureAuthService.hasInternet();
    notifyListeners();
  }

  // Unified Login (Online -> Server, Offline -> SHA-256 Hash / Offline Store)
  Future<bool> login(String email, String password) async {
    _isOnline = await SecureAuthService.hasInternet();

    bool success = false;
    if (_isOnline) {
      success = await SecureAuthService.loginOnline(email, password);
    } else {
      success = await SecureAuthService.loginOffline(email, password);
    }

    if (success) {
      _user = _user.copyWith(
        email: email.isEmpty ? _user.email : email,
        name: email.contains('@') ? email.split('@').first : 'User',
      );
      await OfflineStorageService.saveProfile(_user);
      _isAuthenticated = true;
      notifyListeners();
    }

    return success;
  }

  // Biometric Login (Fingerprint / Face ID)
  Future<bool> biometricLogin() async {
    final success = await SecureAuthService.biometricLogin();
    if (success) {
      final savedEmail = await SecureAuthService.getSavedUserEmail();
      if (savedEmail != null) {
        _user = _user.copyWith(email: savedEmail);
      }
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  // One-Tap Offline Guest Access
  Future<void> loginOfflineGuest({String? email}) async {
    final mail = email?.trim().isNotEmpty == true ? email! : 'guest@kineticfusion.app';
    await SecureAuthService.saveUserSession(email: mail, password: 'guest_user');

    _user = _user.copyWith(
      email: mail,
      name: mail.contains('@') ? mail.split('@').first : 'Guest User',
    );
    await OfflineStorageService.saveProfile(_user);

    _isAuthenticated = true;
    notifyListeners();
  }

  // Update Profile Targets
  Future<void> updateProfile({
    String? name,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    double? targetWeight,
    WeightUnit? weightUnit,
  }) async {
    _user = _user.copyWith(
      name: name,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      targetWeight: targetWeight,
      weightUnit: weightUnit,
    );
    await OfflineStorageService.saveProfile(_user);
    notifyListeners();
  }

  // Secure Logout
  Future<void> logout() async {
    await SecureAuthService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
