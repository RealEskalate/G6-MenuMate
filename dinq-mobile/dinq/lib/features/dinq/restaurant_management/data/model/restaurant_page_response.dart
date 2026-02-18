import 'restaurant_model.dart';

class RestaurantPageResponse {
  final List<RestaurantModel> restaurants;
  final int page;
  final int totalPages;
  final int total;

  RestaurantPageResponse({
    required this.restaurants,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}
