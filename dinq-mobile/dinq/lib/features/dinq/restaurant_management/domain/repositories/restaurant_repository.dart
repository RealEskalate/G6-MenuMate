import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/menu.dart';
import '../entities/restaurant.dart';
import '../entities/review.dart';

abstract class RestaurantRepository {
  // Restaurant
  Future<Either<Failure, Restaurant>> createRestaurant(Restaurant restaurant);
  Future<Either<Failure, List<Restaurant>>> getRestaurants({
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, Restaurant>> getRestaurantBySlug(String slug);
  Future<Either<Failure, Restaurant>> updateRestaurant(
    Restaurant restaurant,
    String slug,
  );
  Future<Either<Failure, void>> deleteRestaurant(String restaurantId);
  // Menu
  Future<Either<Failure, Menu>> uploadMenu(File printedMenu);
  Future<Either<Failure, Menu>> getMenu(String menuId);
  Future<Either<Failure, void>> deleteMenu(String menuId);
  Future<Either<Failure, Menu>> updateMenu(Menu menu);
  // Review
  Future<Either<Failure, List<Review>>> getReviews(String itemId);
  Future<Either<Failure, void>> deleteReview(String reviewId);
  // UserImage
  Future<Either<Failure, List<String>>> getUserImages(String slug);
  // Future<Either<Failure, void>> updateItem();
}
