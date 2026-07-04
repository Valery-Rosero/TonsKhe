import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';

/// The `/` route. While [authProvider] resolves the initial session check it
/// shows a brief spinner; once resolved, a logged-in user is redirected to
/// /home by the router, and a logged-out user sees this "Bienvenida" welcome
/// screen with the entry points into register/login.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: AppLoadingIndicator()),
      );
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.welcomeGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
            child: Column(
              children: [
                const Spacer(),
                Column(
                  children: [
                    const _BrandMark(),
                    const SizedBox(height: 18),
                    Text(
                      'TonsKhe',
                      style: AppTextStyles.heading(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cada aventura, mejor de a dos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.register),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryAccent,
                          shape: const StadiumBorder(),
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          'Crear cuenta',
                          style: AppTextStyles.heading(fontSize: 16, color: AppColors.primaryAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.login),
                      child: Text(
                        'Ya tengo cuenta · Iniciar sesión',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 4,
            child: _dot(Colors.white.withValues(alpha: 0.92)),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: _dot(Colors.white.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
