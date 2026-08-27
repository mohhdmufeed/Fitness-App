import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final success = await auth.sendPasswordReset(_emailController.text.trim());

    if (success && mounted) {
      setState(() => _emailSent = true);
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('RESET PASSWORD'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: const [AppColors.cardShadow],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                          border: Border.all(color: AppColors.cardBorder, width: 1),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.primaryCTA,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your registered email address to receive a secure password reset link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_emailSent) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.accentGreen, width: 1),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: Color(0xFF43755F), size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Password reset link sent! Check your inbox.',
                                style: TextStyle(
                                  color: Color(0xFF43755F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'BACK TO SIGN IN',
                        variant: ButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ] else ...[
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Registered Email',
                        hintText: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !auth.isAuthenticating,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!_emailRegex.hasMatch(val.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'SEND RESET LINK',
                        isLoading: auth.isAuthenticating,
                        onPressed: auth.isAuthenticating ? null : _handleResetPassword,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
