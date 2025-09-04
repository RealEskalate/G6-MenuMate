import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../data/model/restaurant_model.dart';
import '../entities/category.dart';
import '../entities/menu.dart';
import '../entities/restaurant.dart';
import '../entities/review.dart';

abstract class RestaurantRepository {
  // Restaurant
  Future<Either<Failure, Restaurant>> createRestaurant(
    RestaurantModel restaurant,
  );
  Future<Either<Failure, List<Restaurant>>> getRestaurants({
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, Restaurant>> getRestaurantBySlug(String slug);
  Future<Either<Failure, Restaurant>> updateRestaurant(
    RestaurantModel restaurant,
    String slug,
  );
  Future<Either<Failure, void>> deleteRestaurant(String restaurantId);
  // Menu
  Future<Either<Failure, Menu>> getMenu(String restaurantId);
  Future<Either<Failure, void>> updateMenu(Menu menu);
  Future<Either<Failure, List<Category>>> getCategories(
    String tabId,
  ); // TODO: Delete
  //
  Future<Either<Failure, List<Review>>> getReviews(String itemId);
  Future<Either<Failure, List<String>>> getUserImages(String slug);
  Future<Either<Failure, void>> updateItem();
}
