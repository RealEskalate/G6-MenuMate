import '../../repositories/user_repository.dart';

class LoginUserUseCase {
  final UserRepository repository;

  LoginUserUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String identifier,
    required String password,
  }) {
    return repository.loginUser(identifier: identifier, password: password);
  }
}
