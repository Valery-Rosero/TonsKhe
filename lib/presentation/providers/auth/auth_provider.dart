import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/supabase_config.dart';
import '../../../data/datasources/auth/auth_remote_datasource.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/auth/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/recover_password_usecase.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(AuthRemoteDataSource(SupabaseConfig.client));
}

@Riverpod(keepAlive: true)
SignInUseCase signInUseCase(Ref ref) => SignInUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignUpUseCase signUpUseCase(Ref ref) => SignUpUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignOutUseCase signOutUseCase(Ref ref) => SignOutUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
RecoverPasswordUseCase recoverPasswordUseCase(Ref ref) {
  return RecoverPasswordUseCase(ref.watch(authRepositoryProvider));
}

/// Holds the app-wide session state. Emits the signed-in [UserEntity], or
/// null when signed out. The first emission (right after app start) tells
/// the router and the splash page whether there is an active session.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Stream<UserEntity?> build() {
    return ref.watch(authRepositoryProvider).authStateChanges;
  }
}
