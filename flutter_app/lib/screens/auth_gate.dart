import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _biometricChecked = false;
  bool _isCheckingBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricsIfNeeded();
    });
  }

  Future<void> _checkBiometricsIfNeeded() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    if (auth.isAuthenticated && auth.isBiometricsEnabled && !_biometricChecked && !_isCheckingBiometric) {
      setState(() => _isCheckingBiometric = true);

      final passed = await auth.authenticateWithBiometrics();
      if (mounted) {
        setState(() {
          _biometricChecked = passed;
          _isCheckingBiometric = false;
        });

        if (!passed) {
          // If biometric verification was cancelled/failed, sign out to protect session
          await auth.logout();
        }
      }
    } else {
      if (!_biometricChecked && mounted) {
        setState(() => _biometricChecked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // If initial Firebase auth check or biometric prompt is running
    if (auth.isLoading || _isCheckingBiometric) {
      return const SplashScreen();
    }

    // If user is authenticated with Firebase and passed biometric check
    if (auth.isAuthenticated) {
      return const HomePage();
    }

    // Default to Login Page
    return const LoginPage();
  }
}
