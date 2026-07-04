import 'package:flutter/material.dart';

/// "Toxic Pulse" palette — lime + violet on near-black, per the TonsKhe
/// design prototype.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0C10);
  static const Color backgroundGradientTop = Color(0xFF1D2331);
  static const Color backgroundGradientBottom = Color(0xFF12161F);

  static const Color primaryAccent = Color(0xFF8B53FE);
  static const Color secondaryAccent = Color(0xFF8EFF01);

  static const Color surface = Color(0xFF1D2331);
  static const Color border = Color(0xFF2B3345);

  static const Color textPrimary = Color(0xFFF5F5F0);
  static const Color textSecondary = Color(0xFF9A9AA8);
  static const Color textMuted = Color(0xFF8A8A9E);
  static const Color textPlaceholder = Color(0xFF5C5C6B);
  static const Color textBody = Color(0xFFB4B4C2);

  /// Soft pill/badge backgrounds for the two accents.
  static const Color primaryContainer = Color(0xFF241A3D);
  static const Color primaryContainerAlt = Color(0xFF1C1430);
  static const Color secondaryContainer = Color(0xFF1C2410);

  static const Color error = Color(0xFFFF5252);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundGradientTop, backgroundGradientBottom],
  );

  static const LinearGradient welcomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryAccent, Color(0xFF2A1A3D), Color(0xFF2B3345), primaryContainer],
    stops: [0.0, 0.25, 0.55, 1.0],
  );
}
