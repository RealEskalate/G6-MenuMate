import 'package:dio/dio.dart';

import '../../model/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<RestaurantModel> createRestaurant(FormData restaurant);
  Future<List<RestaurantModel>> getRestaurants(
      {int page = 1, int pageSize = 20});
  Future<RestaurantModel> getRestaurantBySlug(String slug);
  Future<RestaurantModel> updateRestaurant(FormData restaurant, String slug);
  Future<void> deleteRestaurant(String restaurantId);
}
