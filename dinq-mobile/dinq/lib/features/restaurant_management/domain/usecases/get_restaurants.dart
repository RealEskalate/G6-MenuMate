import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurants {
  final RestaurantRepository repository;

  GetRestaurants(this.repository);

  Future<Either<Failure, List<Restaurant>>> call({
    int page = 1,
    int pageSize = 1,
  }) async {
    return await repository.getRestaurants();
  }
}
