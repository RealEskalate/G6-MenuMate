
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/error/failures.dart';
import '../entities/restaurant.dart';

abstract class RestaurantRepository {
  // Restaurant
  Future<Either<Failure, Restaurant>> createRestaurant(FormData restaurant);
  Future<Either<Failure, List<Restaurant>>> getRestaurants({
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, Restaurant>> getRestaurantBySlug(String slug);
  Future<Either<Failure, Restaurant>> updateRestaurant(
<<<<<<< HEAD
    Map<String, dynamic> restaurant,
=======
    FormData restaurant,
>>>>>>> origin/mite-test
    String slug,
  );
  Future<Either<Failure, void>> deleteRestaurant(String restaurantId);
  
}
