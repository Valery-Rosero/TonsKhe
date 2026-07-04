String normalizeColombianPhone(String input) {
  final digitsOnly = input.trim().replaceAll(RegExp(r'[^\d+]'), '');
  if (digitsOnly.startsWith('+57')) return digitsOnly;
  if (digitsOnly.startsWith('57')) return '+$digitsOnly';
  if (digitsOnly.startsWith('0')) return '+57${digitsOnly.substring(1)}';
  return '+57$digitsOnly';
}
