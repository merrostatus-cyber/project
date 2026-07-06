import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF081120);
  static const Color surfaceDark = Color(0xFF0D1B2A);
  static const Color cardDark = Color(0xFF0F1D30);
  static const Color cardGlass = Color(0x1AFFFFFF);
  static const Color navy800 = Color(0xFF13243A);
  static const Color navy700 = Color(0xFF1A2D4A);

  // Accent
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentBlueLight = Color(0xFF60A5FA);
  static const Color accentBlueDark = Color(0xFF2563EB);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const Color gradientStart = Color(0xFF3B82F6);
  static const Color gradientEnd = Color(0xFF1D4ED8);
  static const Color gradientGreenStart = Color(0xFF10B981);
  static const Color gradientGreenEnd = Color(0xFF059669);
  static const Color gradientOrangeStart = Color(0xFFF59E0B);
  static const Color gradientOrangeEnd = Color(0xFFD97706);
  static const Color gradientPurpleStart = Color(0xFF8B5CF6);
  static const Color gradientPurpleEnd = Color(0xFF6D28D9);
  static const Color gradientCyanStart = Color(0xFF06B6D4);
  static const Color gradientCyanEnd = Color(0xFF0891B2);

  // Glass effect
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // Glow
  static Color glowBlue = accentBlue.withAlpha(30);
  static Color glowCyan = const Color(0xFF06B6D4).withAlpha(25);

  // Legacy aliases (backward compat)
  static const Color backgroundDark = background;
  static const Color errorRed = error;
  static const Color cyberGreen = success;
  static const Color warningOrange = warning;
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentCyanDark = Color(0xFF0891B2);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(60),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: accentBlue.withAlpha(8),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
