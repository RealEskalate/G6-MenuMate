import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../data/model/restaurant_model.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class UpdateRestaurant {
  final RestaurantRepository repository;

  UpdateRestaurant(this.repository);

  Future<Either<Failure, Restaurant>> call(
    RestaurantModel restaurant,
    String slug,
  ) async {
    return await repository.updateRestaurant(restaurant, slug);
  }
}
