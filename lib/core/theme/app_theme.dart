import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Space Grotesk for headings/wordmark/buttons, Manrope for everything else
/// (set as the app's ambient font via [AppTheme.darkTheme]).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.spaceGrotesk(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      useMaterial3: true,
    );
  }
}
