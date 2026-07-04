import '../entities/auth/user_entity.dart';

abstract class AuthRepository {
  /// Emits the current user (or null) on every auth state change, including
  /// the initial session check when the app starts.
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  });

  Future<UserEntity> signUpWithPhone({
    required String phone,
    required String password,
    required String username,
  });

  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> recoverPasswordByEmail(String email);

  Future<void> sendPhoneRecoveryOtp(String phone);

  Future<void> verifyPhoneOtpAndResetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  });
}
