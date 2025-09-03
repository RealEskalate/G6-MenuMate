import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';

abstract class RestaurantRemoteDataSource {
  // Get methods
  Future<List<Restaurant>> getRestaurants();
  Future<Menu> getMenu(String restaurantId);
  Future<List<Category>> getCategories(String tabId);
  Future<List<Review>> getReviews(String itemId);
  Future<List<String>> getUserImages(String slug);
  
  // Add methods
  Future<Restaurant> addRestaurant(Restaurant restaurant);
  Future<Item> addItem(String categoryId, Item item);
  
  // Update methods
  Future<Restaurant> updateRestaurant(String restaurantId, Restaurant restaurant);
  Future<Menu> updateMenu(String restaurantId, Menu menu);
  Future<Item> updateItem(String itemId, Item item);
  
  // Delete methods
  Future<bool> deleteItem(String itemId);
}
