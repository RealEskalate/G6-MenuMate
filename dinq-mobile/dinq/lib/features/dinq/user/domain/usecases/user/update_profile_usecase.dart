import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    Map<String, dynamic> updates,
  ) => repository.updateProfile(updates);
}
