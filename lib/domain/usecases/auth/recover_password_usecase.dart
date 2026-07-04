import '../../repositories/auth_repository.dart';

enum RecoveryMethod { email, phone }

class RecoverPasswordUseCase {
  final AuthRepository _repository;

  const RecoverPasswordUseCase(this._repository);

  Future<void> call({required RecoveryMethod method, required String identifier}) {
    switch (method) {
      case RecoveryMethod.email:
        return _repository.recoverPasswordByEmail(identifier);
      case RecoveryMethod.phone:
        return _repository.sendPhoneRecoveryOtp(identifier);
    }
  }

  Future<void> verifyOtpAndReset({
    required String phone,
    required String otp,
    required String newPassword,
  }) {
    return _repository.verifyPhoneOtpAndResetPassword(
      phone: phone,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
