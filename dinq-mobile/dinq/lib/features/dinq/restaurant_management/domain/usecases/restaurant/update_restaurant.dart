import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class UpdateRestaurant {
  final RestaurantRepository repository;

  UpdateRestaurant(this.repository);

  Future<Either<Failure, Restaurant>> call(
    Map<String, dynamic> restaurant,
    String slug,
  ) async {
    return await repository.updateRestaurant(restaurant, slug);
  }
}
