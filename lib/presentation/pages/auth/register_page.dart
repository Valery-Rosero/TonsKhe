import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  SignUpMethod _method = SignUpMethod.phone;
  bool _acceptedTerms = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      context.showErrorSnackBar('Debes aceptar los términos y condiciones para continuar.');
      return;
    }

    final identifier = _method == SignUpMethod.phone
        ? normalizeColombianPhone(_identifierController.text)
        : _identifierController.text.trim();

    setState(() => _isSubmitting = true);
    try {
      await ref.read(signUpUseCaseProvider).call(
            method: _method,
            identifier: identifier,
            password: _passwordController.text,
            username: _usernameController.text.trim(),
          );
      if (mounted) context.showSuccessSnackBar('¡Cuenta creada! Bienvenido a TonsKhe.');
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
                  Text('Crear cuenta', style: AppTextStyles.heading(fontSize: 23)),
                  const SizedBox(height: 4),
                  const Text(
                    'Empecemos vuestra historia',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  _SignUpMethodSelector(
                    method: _method,
                    onChanged: _isSubmitting
                        ? null
                        : (method) => setState(() {
                              _method = method;
                              _identifierController.clear();
                            }),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Nombre de usuario',
                    controller: _usernameController,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: Validators.username,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    key: ValueKey(_method),
                    label: _method == SignUpMethod.email ? 'Correo electrónico' : 'Teléfono (+57XXXXXXXXXX)',
                    controller: _identifierController,
                    keyboardType: _method == SignUpMethod.email
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    prefixIcon: _method == SignUpMethod.email ? Icons.mail_outline : Icons.phone_outlined,
                    textInputAction: TextInputAction.next,
                    validator: _method == SignUpMethod.email ? Validators.email : Validators.colombianPhone,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Contraseña',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mínimo 8 caracteres, una mayúscula y un número',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _TermsCheckbox(
                    value: _acceptedTerms,
                    onChanged: _isSubmitting ? null : (value) => setState(() => _acceptedTerms = value),
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: 'Crear cuenta',
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Ya tienes cuenta?',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: _isSubmitting ? null : () => context.pop(),
                        child: const Text(
                          'Inicia sesión',
                          style: TextStyle(color: AppColors.secondaryAccent, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
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

class _SignUpMethodSelector extends StatelessWidget {
  const _SignUpMethodSelector({required this.method, required this.onChanged});

  final SignUpMethod method;
  final ValueChanged<SignUpMethod>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildOption(context, SignUpMethod.phone, 'Teléfono')),
          Expanded(child: _buildOption(context, SignUpMethod.email, 'Correo')),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, SignUpMethod value, String label) {
    final isSelected = method == value;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value ? AppColors.secondaryAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.secondaryAccent, width: 2),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: AppColors.background)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Acepto los términos y condiciones de TonsKhe',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
