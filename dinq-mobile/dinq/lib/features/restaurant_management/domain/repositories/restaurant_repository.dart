import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../entities/menu.dart';
import '../entities/restaurant.dart';
import '../entities/review.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, List<Restaurant>>> getRestaurants();
  Future<Either<Failure, Menu>> getMenu(String restaurantId);
  Future<Either<Failure, List<Category>>> getCategories(String tabId);
  Future<Either<Failure, List<Review>>> getReviews(String itemId);
  Future<Either<Failure, List<String>>> getUserImages(String slug);
}
