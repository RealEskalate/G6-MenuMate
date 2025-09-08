import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

class VerifyEmailUseCase {
  final UserRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String otp}) =>
      repository.verifyEmail(otp: otp);
}
