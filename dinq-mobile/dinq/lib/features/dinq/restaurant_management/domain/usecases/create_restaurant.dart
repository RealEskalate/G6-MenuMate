import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../data/model/restaurant_model.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class CreateRestaurant {
  final RestaurantRepository repository;

  CreateRestaurant(this.repository);

  Future<Either<Failure, Restaurant>> call(RestaurantModel restaurant) async {
    return await repository.createRestaurant(restaurant);
  }
}
