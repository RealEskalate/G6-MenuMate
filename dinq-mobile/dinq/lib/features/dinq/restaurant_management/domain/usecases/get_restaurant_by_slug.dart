import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantBySlug {
  final RestaurantRepository repository;

  GetRestaurantBySlug(this.repository);

  Future<Either<Failure, Restaurant>> call(String slug) async {
    return await repository.getRestaurantBySlug(slug);
  }
}
