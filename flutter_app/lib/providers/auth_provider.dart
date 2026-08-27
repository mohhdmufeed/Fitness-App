import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/connectivity_service.dart';
import '../services/firestore_service.dart';
import '../services/offline_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final BiometricService _biometricService = BiometricService();

  UserModel? _currentUserModel;
  UserProfile _userProfile = UserProfile.defaultProfile();
  User? _firebaseUser;
  bool _isGuestSession = false;
  bool _isLoading = true;
  bool _isAuthenticating = false;
  bool _isOnline = true;
  bool _isBiometricsAvailable = true;
  bool _isBiometricsEnabled = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  UserModel? get userModel => _currentUserModel;
  UserProfile get user => _userProfile;
  User? get firebaseUser => _firebaseUser;
  bool get isAuthenticated => _firebaseUser != null || _currentUserModel != null || _isGuestSession;
  bool get isGuestSession => _isGuestSession;
  bool get isLoading => _isLoading;
  bool get isAuthenticating => _isAuthenticating;
  bool get isOnline => _isOnline;
  bool get isBiometricsAvailable => _isBiometricsAvailable;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load local UserProfile targets
      _userProfile = await OfflineStorageService.loadUserProfile();

      // Check if a saved local user session exists
      final savedUser = await _authService.getActiveSavedUser();
      if (savedUser != null) {
        _currentUserModel = savedUser;
        _userProfile = _userProfile.copyWith(
          name: savedUser.name,
          email: savedUser.email,
          isGuest: false,
        );
      }

      // Check connectivity
      _isOnline = await _connectivityService.hasInternet();
      _connectivitySubscription =
          _connectivityService.connectionStream.listen((hasConnection) {
        _isOnline = hasConnection;
        notifyListeners();
      });

      // Check biometrics capability & preference
      _isBiometricsAvailable = await _biometricService.isBiometricsAvailable();
      _isBiometricsEnabled = await _biometricService.isBiometricEnabled();

      // Listen to Firebase Auth state stream
      _authSubscription = _authService.authStateChanges.listen((User? user) async {
        _firebaseUser = user;
        if (user != null) {
          try {
            _currentUserModel = await _firestoreService.getUserProfile(user.uid);
          } catch (_) {}
          _userProfile = _userProfile.copyWith(
            name: user.displayName ?? _userProfile.name,
            email: user.email ?? _userProfile.email,
            isGuest: false,
          );
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Auth initialization note: $e');
      _isLoading = false;
      notifyListeners();
    }

    // Safety timeout: Ensure loading is dismissed within 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Register new user with Firebase Auth & Cloud Firestore + Secure Engine
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isAuthenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUserModel = await _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      _isGuestSession = false;
      _userProfile = _userProfile.copyWith(
        name: name,
        email: email,
        isGuest: false,
      );
      await OfflineStorageService.saveUserProfile(_userProfile);

      _isAuthenticating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticating = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in existing user with Firebase Auth or Secure Engine
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isAuthenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUserModel = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isGuestSession = false;
      _userProfile = _userProfile.copyWith(
        name: _currentUserModel?.name ?? 'Athlete',
        email: email,
        isGuest: false,
      );
      await OfflineStorageService.saveUserProfile(_userProfile);

      _isAuthenticating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticating = false;
      notifyListeners();
      return false;
    }
  }

  /// Positional parameter overload for backward compatibility
  Future<bool> loginWithCredentials(String email, String password) =>
      login(email: email, password: password);

  /// Guest offline login fallback
  Future<bool> loginOfflineGuest({String? email}) async {
    _isGuestSession = true;
    _currentUserModel = null;
    _userProfile = _userProfile.copyWith(
      name: 'Athlete',
      email: email != null && email.isNotEmpty ? email : 'athlete@kineticfusion.local',
      isGuest: true,
    );
    await OfflineStorageService.saveUserProfile(_userProfile);
    notifyListeners();
    return true;
  }

  /// Authenticate using device biometrics (fingerprint / Face ID)
  Future<bool> authenticateWithBiometrics() async {
    _errorMessage = null;
    try {
      final success = await _biometricService.authenticateWithBiometrics(
        reason: 'Authenticate to access Kinetic Fusion',
      );

      if (success) {
        if (_firebaseUser != null) {
          try {
            _currentUserModel =
                await _firestoreService.getUserProfile(_firebaseUser!.uid);
          } catch (_) {}
        } else {
          _isGuestSession = true;
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Biometric authentication was cancelled.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Biometric hardware unavailable.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> biometricLogin() => authenticateWithBiometrics();

  /// Update user profile & nutrition targets
  Future<void> updateProfile({
    String? name,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    double? targetWeight,
    WeightUnit? weightUnit,
  }) async {
    _userProfile = _userProfile.copyWith(
      name: name,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      targetWeight: targetWeight,
      weightUnit: weightUnit,
    );

    await OfflineStorageService.saveUserProfile(_userProfile);

    // If connected to Firebase, sync name update to Cloud Firestore
    if (_firebaseUser != null && name != null) {
      try {
        await _firestoreService.updateUserProfile(_firebaseUser!.uid, {
          'name': name,
        });
      } catch (_) {}
    }

    notifyListeners();
  }

  /// Toggle user's biometric login preference
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _biometricService.setBiometricEnabled(enabled);
    _isBiometricsEnabled = enabled;
    notifyListeners();
  }

  /// Send password reset link to user's registered email
  Future<bool> sendPasswordReset(String email) async {
    _isAuthenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isAuthenticating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticating = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
    } catch (_) {}

    _currentUserModel = null;
    _firebaseUser = null;
    _isGuestSession = false;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
}
