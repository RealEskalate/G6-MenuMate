import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoriteRestaurantsKey = 'favorite_restaurants';
  static const String _favoriteDishesKey = 'favorite_dishes';
  
  // Singleton instance
  static final FavoritesService _instance = FavoritesService._internal();
  
  factory FavoritesService() {
    return _instance;
  }
  
  FavoritesService._internal();
  
  // Get favorite restaurant IDs
  Future<Set<String>> getFavoriteRestaurantIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> restaurantIds = prefs.getStringList(_favoriteRestaurantsKey) ?? [];
    return restaurantIds.toSet();
  }
  
  // Save favorite restaurant IDs
  Future<bool> saveFavoriteRestaurantIds(Set<String> restaurantIds) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_favoriteRestaurantsKey, restaurantIds.toList());
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
  
  // Check if a restaurant is favorited
  Future<bool> isRestaurantFavorite(String restaurantId) async {
    final restaurantIds = await getFavoriteRestaurantIds();
    return restaurantIds.contains(restaurantId);
  }
  
  // Toggle restaurant favorite status
  Future<bool> toggleFavoriteRestaurant(String restaurantId) async {
    final isFavorite = await isRestaurantFavorite(restaurantId);
    if (isFavorite) {
      return removeFavoriteRestaurant(restaurantId);
    } else {
      return addFavoriteRestaurant(restaurantId);
    }
  }
  
  // Get favorite dish IDs
  Future<Set<String>> getFavoriteDishIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> dishIds = prefs.getStringList(_favoriteDishesKey) ?? [];
    return dishIds.toSet();
  }
  
  // Save favorite dish IDs
  Future<bool> saveFavoriteDishIds(Set<String> dishIds) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_favoriteDishesKey, dishIds.toList());
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
  
  // Check if a dish is favorited
  Future<bool> isDishFavorite(String dishId) async {
    final dishIds = await getFavoriteDishIds();
    return dishIds.contains(dishId);
  }
  
  // Toggle dish favorite status
  Future<bool> toggleFavoriteDish(String dishId) async {
    final isFavorite = await isDishFavorite(dishId);
    if (isFavorite) {
      return removeFavoriteDish(dishId);
    } else {
      return addFavoriteDish(dishId);
    }
  }
}