import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';

import '../repositories/user_repository.dart';

class ClearFavoritesUseCase {
  final UserRepository repository;

  ClearFavoritesUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.clearFavorites();
  }
}
