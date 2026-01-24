import 'dart:io';
import 'package:dio/dio.dart';

import '../model/menu_model.dart';
import '../model/restaurant_model.dart';
import '../model/review_model.dart';

abstract class RestaurantRemoteDataSource {
  // Restaurant
  Future<RestaurantModel> createRestaurant(FormData restaurant);
  Future<List<RestaurantModel>> getRestaurants({
    int page = 1,
    int pageSize = 20,
  });
  Future<List<RestaurantModel>> searchRestaurants({
    required String name,
    int page = 1,
    int pageSize = 10,
  });
  Future<RestaurantModel> getRestaurantBySlug(String slug);
  Future<RestaurantModel> updateRestaurant(
    Map<String, dynamic> restaurant,
    String slug,
  );
  Future<void> deleteRestaurant(String restaurantId);

  // Menu
  Future<MenuModel> uploadMenu(File printedMenu);
  Future<MenuModel> getMenu(String menuId);
  Future<void> deleteMenu(String menuId);
  Future<MenuModel> updateMenu(MenuModel menu);

  // Review
  Future<List<ReviewModel>> getReviews(String itemId);
  Future<void> deleteReview(String reviewId);

  // UserImage
  Future<List<String>> getUserImages(String slug);
}
