import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class RegisterUserUseCase {
  final UserRepository repository;

  RegisterUserUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    String? firstName,
    String? lastName,
    String? role,
  }) {
    return repository.registerUser(
      username: username,
      email: email,
      password: password,
      authProvider: authProvider,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );
  }
}
