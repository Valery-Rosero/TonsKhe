class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _colombianPhoneRegex = RegExp(r'^\+57\d{10}$');
  static final RegExp _uppercaseRegex = RegExp('[A-Z]');
  static final RegExp _digitRegex = RegExp('[0-9]');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'El correo es obligatorio';
    if (!_emailRegex.hasMatch(trimmed)) return 'Ingresa un correo válido';
    return null;
  }

  static String? colombianPhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'El teléfono es obligatorio';
    if (!_colombianPhoneRegex.hasMatch(trimmed)) {
      return 'Ingresa un teléfono colombiano válido (+57XXXXXXXXXX)';
    }
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'La contraseña es obligatoria';
    if (input.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!_uppercaseRegex.hasMatch(input)) return 'Debe incluir al menos una mayúscula';
    if (!_digitRegex.hasMatch(input)) return 'Debe incluir al menos un número';
    return null;
  }

  static String? username(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'El nombre de usuario es obligatorio';
    if (trimmed.length < 3) return 'Debe tener al menos 3 caracteres';
    return null;
  }

  static String? otp(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'El código es obligatorio';
    if (trimmed.length < 6) return 'El código debe tener 6 dígitos';
    return null;
  }
}
