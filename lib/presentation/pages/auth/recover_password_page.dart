import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/usecases/auth/recover_password_usecase.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

enum _Step { request, verifyPhone }

class RecoverPasswordPage extends ConsumerStatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  ConsumerState<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends ConsumerState<RecoverPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  RecoveryMethod _method = RecoveryMethod.email;
  _Step _step = _Step.request;
  bool _isSubmitting = false;
  String? _pendingPhone;

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final identifier = _method == RecoveryMethod.phone
        ? normalizeColombianPhone(_identifierController.text)
        : _identifierController.text.trim();

    setState(() => _isSubmitting = true);
    try {
      await ref.read(recoverPasswordUseCaseProvider).call(method: _method, identifier: identifier);
      if (!mounted) return;
      if (_method == RecoveryMethod.email) {
        context.showSuccessSnackBar('Te enviamos instrucciones a tu correo.');
        context.pop();
      } else {
        setState(() {
          _pendingPhone = identifier;
          _step = _Step.verifyPhone;
        });
        context.showSuccessSnackBar('Te enviamos un código por SMS.');
      }
    } on AppException catch (error) {
      if (mounted) context.showErrorSnackBar(error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitVerifyPhone() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(recoverPasswordUseCaseProvider).verifyOtpAndReset(
            phone: _pendingPhone!,
            otp: _otpController.text.trim(),
            newPassword: _newPasswordController.text,
          );
      if (!mounted) return;
      context.showSuccessSnackBar('Contraseña actualizada.');
      context.pop();
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
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  _step == _Step.request ? _buildRequestStep() : _buildVerifyPhoneStep(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestStep() {
    return Column(
      key: const ValueKey('request'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 88,
            height: 88,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(color: AppColors.primaryContainerAlt, shape: BoxShape.circle),
            child: const Icon(Icons.lock_outline, color: AppColors.primaryAccent, size: 32),
          ),
        ),
        Text('¿Se te olvidó?', textAlign: TextAlign.center, style: AppTextStyles.heading(fontSize: 21)),
        const SizedBox(height: 4),
        const Text(
          'Tranquilo, os ayudamos a recuperar el acceso',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 28),
        SegmentedButton<RecoveryMethod>(
          segments: const [
            ButtonSegment(value: RecoveryMethod.email, label: Text('Correo')),
            ButtonSegment(value: RecoveryMethod.phone, label: Text('Teléfono')),
          ],
          selected: {_method},
          onSelectionChanged: _isSubmitting
              ? null
              : (selection) => setState(() {
                    _method = selection.first;
                    _identifierController.clear();
                  }),
        ),
        const SizedBox(height: 16),
        AppTextField(
          key: ValueKey(_method),
          label: _method == RecoveryMethod.email ? 'Correo electrónico' : 'Teléfono (+57XXXXXXXXXX)',
          controller: _identifierController,
          keyboardType: _method == RecoveryMethod.email ? TextInputType.emailAddress : TextInputType.phone,
          prefixIcon: _method == RecoveryMethod.email ? Icons.mail_outline : Icons.phone_outlined,
          validator: _method == RecoveryMethod.email ? Validators.email : Validators.colombianPhone,
        ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          label: 'Enviar código',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submitRequest,
        ),
      ],
    );
  }

  Widget _buildVerifyPhoneStep() {
    return Column(
      key: const ValueKey('verify'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Verifica el código', style: AppTextStyles.heading(fontSize: 21)),
        const SizedBox(height: 4),
        Text(
          'Ingresa el código enviado a $_pendingPhone y tu nueva contraseña',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 28),
        AppTextField(
          label: 'Código de verificación',
          controller: _otpController,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.pin_outlined,
          validator: Validators.otp,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Nueva contraseña',
          controller: _newPasswordController,
          obscureText: true,
          prefixIcon: Icons.lock_outline,
          validator: Validators.password,
        ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          label: 'Actualizar contraseña',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submitVerifyPhone,
        ),
      ],
    );
  }
}
