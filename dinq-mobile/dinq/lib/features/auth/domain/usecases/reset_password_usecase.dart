import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../repositories/user_repository.dart';

class ResetPasswordUseCase {
  final UserRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String token,
    required String newPassword,
  }) {
    return repository.resetPassword(token: token, newPassword: newPassword);
  }
}
