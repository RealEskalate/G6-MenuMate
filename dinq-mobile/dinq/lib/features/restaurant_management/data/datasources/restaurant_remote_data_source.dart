import 'package:dinq/features/restaurant_management/domain/entities/category.dart';
import 'package:dinq/features/restaurant_management/domain/entities/menu.dart';
import 'package:dinq/features/restaurant_management/domain/entities/restaurant.dart';
import 'package:dinq/features/restaurant_management/domain/entities/review.dart';

abstract class RestaurantRemoteDataSource {
  
  Future<List<Restaurant>> getRestaurants();
  Future<Menu> getMenu(String restaurantId);
  Future<List<Category>> getCategories(String tabId);
  Future<List<Review>> getReviews(String itemId);
  Future<List<String>> getUserImages(String slug);
}
