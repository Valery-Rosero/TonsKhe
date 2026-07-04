import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppSnackBar {
  AppSnackBar._();

  static void showError(BuildContext context, String message) {
    _show(context, message: message, background: AppColors.error);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, background: AppColors.secondaryAccent, textColor: AppColors.background);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color background,
    Color textColor = AppColors.textPrimary,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: textColor)),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}
