import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/restaurant_management/domain/entities/restaurant.dart';
import 'package:dinq/features/restaurant_management/domain/repositories/restaurant_repository.dart';

class GetRestaurants {
  final RestaurantRepository repository;

  GetRestaurants(this.repository);

  Future<Either<Failure, List<Restaurant>>> call() async {
    return await repository.getRestaurants();
  }
}
