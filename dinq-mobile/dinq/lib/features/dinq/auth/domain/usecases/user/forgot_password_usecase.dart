import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

class ForgotPasswordUseCase {
  final UserRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String email}) =>
      repository.forgotPassword(email: email);
}
