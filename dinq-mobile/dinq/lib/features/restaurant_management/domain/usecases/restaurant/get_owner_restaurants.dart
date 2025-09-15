import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class GetOwnerRestaurants {
  final RestaurantRepository repository;

  GetOwnerRestaurants(this.repository);

  Future<Either<Failure, List<Restaurant>>> call() async {
    return await repository.getOwnerRestaurants();
  }
}
