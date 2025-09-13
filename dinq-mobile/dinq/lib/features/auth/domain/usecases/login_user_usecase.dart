import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class LoginUserUseCase {
  final UserRepository repository;

  LoginUserUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String identifier,
    required String password,
  }) {
    return repository.loginUser(identifier: identifier, password: password);
  }
}
