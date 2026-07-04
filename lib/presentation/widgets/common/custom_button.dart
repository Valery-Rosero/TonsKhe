import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'loading_widget.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.primaryAccent.withValues(alpha: 0.6),
          shape: const StadiumBorder(),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.35),
        ),
        child: isLoading
            ? const AppLoadingIndicator(size: 22)
            : Text(label, style: AppTextStyles.heading(fontSize: 16)),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          side: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
          shape: const StadiumBorder(),
        ),
        child: isLoading
            ? const AppLoadingIndicator(size: 22)
            : Text(label, style: AppTextStyles.heading(fontSize: 16, color: AppColors.primaryAccent)),
      ),
    );
  }
}
