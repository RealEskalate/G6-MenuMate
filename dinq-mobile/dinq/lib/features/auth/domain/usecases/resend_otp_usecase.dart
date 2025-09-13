import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../repositories/user_repository.dart';

class ResendOtpUseCase {
  final UserRepository repository;

  ResendOtpUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String email}) =>
      repository.resendOtp(email: email);
}
