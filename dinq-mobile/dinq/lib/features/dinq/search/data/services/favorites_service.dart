import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _restaurantIdsKey = 'favorite_restaurant_ids';
  static const String _dishIdsKey = 'favorite_dish_ids';

  // Get favorite restaurant IDs from SharedPreferences
  Future<Set<String>> getFavoriteRestaurantIds() async {
    final prefs = await SharedPreferences.getInstance();
    final restaurantIds = prefs.getStringList(_restaurantIdsKey) ?? [];
    return restaurantIds.toSet();
  }

  // Get favorite dish IDs from SharedPreferences
  Future<Set<String>> getFavoriteDishIds() async {
    final prefs = await SharedPreferences.getInstance();
    final dishIds = prefs.getStringList(_dishIdsKey) ?? [];
    return dishIds.toSet();
  }

  // Save favorite restaurant IDs to SharedPreferences
  Future<bool> saveFavoriteRestaurantIds(Set<String> restaurantIds) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_restaurantIdsKey, restaurantIds.toList());
  }

  // Save favorite dish IDs to SharedPreferences
  Future<bool> saveFavoriteDishIds(Set<String> dishIds) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_dishIdsKey, dishIds.toList());
  }

  // Add a restaurant to favorites
  Future<bool> addFavoriteRestaurant(String restaurantId) async {
    final restaurantIds = await getFavoriteRestaurantIds();
    restaurantIds.add(restaurantId);
    return saveFavoriteRestaurantIds(restaurantIds);
  }

  // Remove a restaurant from favorites
  Future<bool> removeFavoriteRestaurant(String restaurantId) async {
    final restaurantIds = await getFavoriteRestaurantIds();
    restaurantIds.remove(restaurantId);
    return saveFavoriteRestaurantIds(restaurantIds);
  }

  // Add a dish to favorites
  Future<bool> addFavoriteDish(String dishId) async {
    final dishIds = await getFavoriteDishIds();
    dishIds.add(dishId);
    return saveFavoriteDishIds(dishIds);
  }

  // Remove a dish from favorites
  Future<bool> removeFavoriteDish(String dishId) async {
    final dishIds = await getFavoriteDishIds();
    dishIds.remove(dishId);
    return saveFavoriteDishIds(dishIds);
  }

  // Check if a restaurant is in favorites
  Future<bool> isRestaurantFavorite(String restaurantId) async {
    final restaurantIds = await getFavoriteRestaurantIds();
    return restaurantIds.contains(restaurantId);
  }

  // Check if a dish is in favorites
  Future<bool> isDishFavorite(String dishId) async {
    final dishIds = await getFavoriteDishIds();
    return dishIds.contains(dishId);
  }

  // Toggle a restaurant's favorite status
  Future<bool> toggleRestaurantFavorite(String restaurantId) async {
    final isFavorite = await isRestaurantFavorite(restaurantId);
    if (isFavorite) {
      await removeFavoriteRestaurant(restaurantId);
      return false;
    } else {
      await addFavoriteRestaurant(restaurantId);
      return true;
    }
  }

  // Toggle a dish's favorite status
  Future<bool> toggleDishFavorite(String dishId) async {
    final isFavorite = await isDishFavorite(dishId);
    if (isFavorite) {
      await removeFavoriteDish(dishId);
      return false;
    } else {
      await addFavoriteDish(dishId);
      return true;
    }
  }
}