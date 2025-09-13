import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';

import '../repositories/user_repository.dart';

class GetFavoriteRestaurantIdsUseCase {
  final UserRepository repository;

  GetFavoriteRestaurantIdsUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getFavoriteRestaurants();
  }
}
