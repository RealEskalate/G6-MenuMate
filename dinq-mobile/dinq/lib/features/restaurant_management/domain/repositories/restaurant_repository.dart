import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/restaurant_management/domain/entities/category.dart';
import 'package:dinq/features/restaurant_management/domain/entities/menu.dart';
import 'package:dinq/features/restaurant_management/domain/entities/restaurant.dart';
import 'package:dinq/features/restaurant_management/domain/entities/review.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, List<Restaurant>>> getRestaurants();
  Future<Either<Failure, Menu>> getMenu(String restaurantId);
  Future<Either<Failure, List<Category>>> getCategories(String tabId);
  Future<Either<Failure, List<Review>>> getReviews(String itemId);
  Future<Either<Failure, List<String>>> getUserImages(String slug);
}
