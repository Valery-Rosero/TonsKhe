import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/auth/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth/auth_remote_datasource.dart';
import '../models/auth/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.onAuthStateChange.asyncMap((authState) async {
      final user = authState.session?.user;
      if (user == null) return null;
      try {
        return await _buildUserModel(user);
      } catch (_) {
        return null;
      }
    });
  }

  Future<UserModel> _buildUserModel(User user) async {
    // The `profiles` row is created by the `handle_new_user` trigger in the
    // same transaction as the auth.users insert, but we allow one short
    // retry in case a fresh sign-up is read back before it's visible yet.
    try {
      final profile = await _remoteDataSource.getProfile(user.id);
      return UserModel.fromSupabase(user, profile);
    } on PostgrestException {
      await Future.delayed(const Duration(milliseconds: 400));
      final profile = await _remoteDataSource.getProfile(user.id);
      return UserModel.fromSupabase(user, profile);
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) {
    return _runAuth(() async {
      final response = await _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
      return _requireUser(response);
    });
  }

  @override
  Future<UserEntity> signUpWithPhone({
    required String phone,
    required String password,
    required String username,
  }) {
    return _runAuth(() async {
      final response = await _remoteDataSource.signUpWithPhone(
        phone: phone,
        password: password,
        username: username,
      );
      return _requireUser(response);
    });
  }

  @override
  Future<UserEntity> signInWithEmail({required String email, required String password}) {
    return _runAuth(() async {
      final response = await _remoteDataSource.signInWithEmail(email: email, password: password);
      return _requireUser(response);
    });
  }

  @override
  Future<void> signOut() {
    return _runAuth(() => _remoteDataSource.signOut());
  }

  @override
  Future<void> recoverPasswordByEmail(String email) {
    return _runAuth(() => _remoteDataSource.recoverPasswordByEmail(email));
  }

  @override
  Future<void> sendPhoneRecoveryOtp(String phone) {
    return _runAuth(() => _remoteDataSource.sendPhoneRecoveryOtp(phone));
  }

  @override
  Future<void> verifyPhoneOtpAndResetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) {
    return _runAuth(() async {
      await _remoteDataSource.verifyPhoneOtp(phone: phone, otp: otp);
      await _remoteDataSource.updatePassword(newPassword);
    });
  }

  Future<UserEntity> _requireUser(AuthResponse response) async {
    final user = response.user;
    if (user == null) {
      throw const AppException('No fue posible completar la operación. Intenta de nuevo.');
    }
    return _buildUserModel(user);
  }

  Future<T> _runAuth<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (error) {
      throw _mapAuthError(error);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  AppException _mapAuthError(AuthException error) {
    switch (error.code) {
      case 'email_exists':
      case 'user_already_exists':
        return const AppException('Este correo ya está registrado.');
      case 'phone_exists':
        return const AppException('Este número ya está registrado.');
      case 'weak_password':
        return const AppException('La contraseña no cumple los requisitos de seguridad.');
      case 'invalid_credentials':
        return const AppException('Correo o contraseña incorrectos.');
      case 'otp_expired':
        return const AppException('El código ha expirado. Solicita uno nuevo.');
      case 'over_email_send_rate_limit':
      case 'over_sms_send_rate_limit':
      case 'over_request_rate_limit':
        return const AppException('Demasiados intentos. Intenta de nuevo en unos minutos.');
      case 'user_not_found':
        return const AppException('No encontramos una cuenta con esos datos.');
      default:
        if (error.statusCode == '400' || error.statusCode == '401') {
          return const AppException('Correo o contraseña incorrectos.');
        }
        return const AppException('No fue posible completar la operación. Intenta de nuevo.');
    }
  }
}
