import 'package:equatable/equatable.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends RestaurantEvent {
  const LoadRestaurants();
}

class LoadMenu extends RestaurantEvent {
  final String restaurantId;

  const LoadMenu(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class LoadCategories extends RestaurantEvent {
  final String tabId;

  const LoadCategories(this.tabId);

  @override
  List<Object?> get props => [tabId];
}

class LoadReviews extends RestaurantEvent {
  final String itemId;

  const LoadReviews(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class LoadUserImages extends RestaurantEvent {
  final String slug;

  const LoadUserImages(this.slug);

  @override
  List<Object?> get props => [slug];
}
