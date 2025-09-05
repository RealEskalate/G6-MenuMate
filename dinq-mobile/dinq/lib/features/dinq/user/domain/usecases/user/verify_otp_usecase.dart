import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

class VerifyOtpUseCase {
  final UserRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String otp,
    required String identifier,
  }) => repository.verifyOtp(otp: otp, identifier: identifier);
}
