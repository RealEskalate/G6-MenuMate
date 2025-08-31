import '../../domain/entities/category.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';

abstract class RestaurantRemoteDataSource {
  
  Future<List<Restaurant>> getRestaurants();
  Future<Menu> getMenu(String restaurantId);
  Future<List<Category>> getCategories(String tabId);
  Future<List<Review>> getReviews(String itemId);
  Future<List<String>> getUserImages(String slug);
}
