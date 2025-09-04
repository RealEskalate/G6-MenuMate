import '../model/menu_model.dart';
import '../model/restaurant_model.dart';
import '../model/review_model.dart';

abstract class RestaurantRemoteDataSource {
  // Restaurant
  Future<RestaurantModel> createRestaurant(RestaurantModel restaurant);
  Future<List<RestaurantModel>> getRestaurants({
    int page = 1,
    int pageSize = 20,
  });
  Future<RestaurantModel> getRestaurantBySlug(String slug);
  Future<RestaurantModel> updateRestaurant(
    RestaurantModel restaurant,
    String slug,
  );
  Future<void> deleteRestaurant(String restaurantId);

  // Menu
  Future<MenuModel> getMenu(String menuId);
  Future<void> deleteMenu(String menuId);
  Future<MenuModel> updateMenu(MenuModel menu);

  // Review
  Future<List<ReviewModel>> getReviews(String itemId);
  Future<void> deleteReview(String reviewId);

  // UserImage
  Future<List<String>> getUserImages(String slug);
}
