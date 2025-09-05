import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

class GetGoogleRedirectUseCase {
  final UserRepository repository;

  GetGoogleRedirectUseCase(this.repository);

  Future<Either<Failure, String>> call() =>
      repository.getGoogleLoginRedirectUrl();
}
