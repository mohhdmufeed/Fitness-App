import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SecureAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _keyEmail = 'kf_secure_user_email';
  static const String _keyPasswordHash = 'kf_secure_password_hash';
  static const String _keyIsLoggedIn = 'kf_secure_is_logged_in';

  // 1. Detect Real-Time Internet Connectivity
  static Future<bool> hasInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  // 2. SHA-256 Password Hashing
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // 3. Store Secure Offline Credentials & Session
  static Future<void> saveUserSession({
    required String email,
    required String password,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPasswordHash, hashPassword(password));
    await prefs.setBool(_keyIsLoggedIn, true);

    if (token != null) {
      await ApiService.saveJwtToken(token);
    }
  }

  // 4. Online Login Flow
  static Future<bool> loginOnline(String email, String password) async {
    try {
      // In production: send credentials to AWS/Firebase backend
      // Generate secure session token
      final dummyJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.${base64Url.encode(utf8.encode(email))}.signature";
      
      await saveUserSession(email: email, password: password, token: dummyJwt);
      return true;
    } catch (_) {
      return false;
    }
  }

  // 5. Secure Offline Login Flow with SHA-256 Hash Matching
  static Future<bool> loginOffline(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(_keyEmail);
      final savedHash = prefs.getString(_keyPasswordHash);

      // If first offline guest launch
      if (savedEmail == null && savedHash == null) {
        await saveUserSession(email: email.isEmpty ? 'guest@kineticfusion.app' : email, password: password.isEmpty ? 'guest' : password);
        return true;
      }

      final inputHash = hashPassword(password);
      return (email.toLowerCase().trim() == savedEmail?.toLowerCase().trim()) && (inputHash == savedHash);
    } catch (_) {
      return false;
    }
  }

  // 6. Biometric Fingerprint / Face ID Authentication
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> biometricLogin() async {
    try {
      final canAuth = await canCheckBiometrics();
      if (!canAuth) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Kinetic Fusion',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // 7. Check if active session exists
  static Future<String?> getSavedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<bool> isUserSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // 8. Secure Logout Flow
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await ApiService.clearJwtToken();
  }
}
