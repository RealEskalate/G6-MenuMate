import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';

import '../repositories/user_repository.dart';

class SaveFavoriteRestaurantIdsUseCase {
  final UserRepository repository;

  SaveFavoriteRestaurantIdsUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.saveFavoriteRestaurantIds(id);
  }
}
