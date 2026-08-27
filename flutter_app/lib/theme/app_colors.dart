import 'package:flutter/material.dart';

class AppColors {
  // Page Background throughout (Warm Off-White)
  static const Color background = Color(0xFFEEEBE3);

  // Card / Surface Backgrounds (Pure White & Soft Card Surfaces)
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFF7F5F0);
  static const Color cardBorder = Color(0x4DC5CCC9); // 30% Gray-Green border

  // Hairline separators and borders
  static const Color divider = Color(0x40C5CCC9);
  static const Color borderSecondary = Color(0xFFC5CCC9);

  // Typography Tokens
  static const Color textPrimary = Color(0xFF171E19); // Charcoal
  static const Color textSecondary = Color(0xB3171E19); // 70% Charcoal
  static const Color textMuted = Color(0x66171E19); // 40% Charcoal

  // Primary Action & Branding (Pastel Muted Red)
  static const Color primaryCTA = Color(0xFFD64848);
  static const Color accentRed = Color(0xFFD64848);

  // Success / Active Accents (Soft Sage Green)
  static const Color accentGreen = Color(0xFF8EB5A2);
  static const Color accentGreenLight = Color(0xFFA3C7B5);

  // Functional Accents
  static const Color accentTeal = Color(0xFF6DA5A8);
  static const Color accentCyan = Color(0xFF5B9EAD);
  static const Color accentPurple = Color(0xFF8B82A8);
  static const Color accentOrange = Color(0xFFD8854E);
  static const Color accentYellow = Color(0xFFD4B157);

  // Navigation & Buttons
  static const Color navBar = Color(0xFFFFFFFF);
  static const Color buttonDisabled = Color(0xFFE2DFD7);

  // Soft Ambient Box Shadow
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F000000), // rgba(0,0,0,0.06)
    blurRadius: 30,
    offset: Offset(0, 15),
  );
}
