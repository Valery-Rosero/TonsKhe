import '../../entities/auth/user_entity.dart';
import '../../repositories/auth_repository.dart';

enum SignUpMethod { email, phone }

class SignUpUseCase {
  final AuthRepository _repository;

  const SignUpUseCase(this._repository);

  Future<UserEntity> call({
    required SignUpMethod method,
    required String identifier,
    required String password,
    required String username,
  }) {
    switch (method) {
      case SignUpMethod.email:
        return _repository.signUpWithEmail(
          email: identifier,
          password: password,
          username: username,
        );
      case SignUpMethod.phone:
        return _repository.signUpWithPhone(
          phone: identifier,
          password: password,
          username: username,
        );
    }
  }
}
