import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class UpdateRestaurant {
  final RestaurantRepository repository;

  UpdateRestaurant(this.repository);

  Future<Either<Failure, Restaurant>> call(
    FormData restaurant,
    String slug,
  ) async {
    return await repository.updateRestaurant(restaurant, slug);
  }
}
