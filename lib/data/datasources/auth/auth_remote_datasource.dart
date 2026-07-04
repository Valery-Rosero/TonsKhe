import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;

  const AuthRemoteDataSource(this._client);

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<Map<String, dynamic>> getProfile(String userId) async {
    return _client.from('profiles').select().eq('id', userId).single();
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<AuthResponse> signUpWithPhone({
    required String phone,
    required String password,
    required String username,
  }) {
    return _client.auth.signUp(
      phone: phone,
      password: password,
      data: {'username': username},
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> recoverPasswordByEmail(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<void> sendPhoneRecoveryOtp(String phone) {
    return _client.auth.signInWithOtp(phone: phone, shouldCreateUser: false);
  }

  Future<AuthResponse> verifyPhoneOtp({required String phone, required String otp}) {
    return _client.auth.verifyOTP(phone: phone, token: otp, type: OtpType.sms);
  }

  Future<UserResponse> updatePassword(String newPassword) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
