import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../providers/stories/stories_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

const _codeLength = 6;

class JoinStoryPage extends ConsumerStatefulWidget {
  const JoinStoryPage({super.key});

  @override
  ConsumerState<JoinStoryPage> createState() => _JoinStoryPageState();
}

class _JoinStoryPageState extends ConsumerState<JoinStoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String? _validateCode(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) return 'El código es obligatorio';
    if (code.length != _codeLength) return 'El código debe tener $_codeLength caracteres';
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(code)) return 'Solo letras y números';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final story = await ref.read(joinStoryUseCaseProvider).call(
            inviteCode: _codeController.text.trim(),
          );
      if (mounted) context.go(AppRoutes.storyCategories(story.id));
    } on AppException catch (error) {
      if (mounted) context.showErrorSnackBar(error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IconButton(
                    onPressed: _isSubmitting ? null : () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Icon(Icons.group_add_outlined, color: AppColors.primaryAccent, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text('Unirse a una Historia', textAlign: TextAlign.center, style: AppTextStyles.heading(fontSize: 20)),
                  const SizedBox(height: 4),
                  const Text(
                    'Pídele el código a tu compañero/a de aventuras',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    label: 'Código de invitación',
                    controller: _codeController,
                    textInputAction: TextInputAction.done,
                    maxLength: _codeLength,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                      _UpperCaseTextFormatter(),
                    ],
                    validator: _validateCode,
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: 'Unirme',
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
