import 'package:equatable/equatable.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';

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

class AddRestaurantEvent extends RestaurantEvent {
  final Restaurant restaurant;

  const AddRestaurantEvent(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class AddItemEvent extends RestaurantEvent {
  final String categoryId;
  final Item item;

  const AddItemEvent(this.categoryId, this.item);

  @override
  List<Object?> get props => [categoryId, item];
}

class UpdateRestaurantEvent extends RestaurantEvent {
  final String restaurantId;
  final Restaurant restaurant;

  const UpdateRestaurantEvent(this.restaurantId, this.restaurant);

  @override
  List<Object?> get props => [restaurantId, restaurant];
}

class UpdateMenuEvent extends RestaurantEvent {
  final String restaurantId;
  final Menu menu;

  const UpdateMenuEvent(this.restaurantId, this.menu);

  @override
  List<Object?> get props => [restaurantId, menu];
}

class UpdateItemEvent extends RestaurantEvent {
  final String itemId;
  final Item item;

  const UpdateItemEvent(this.itemId, this.item);

  @override
  List<Object?> get props => [itemId, item];
}

class DeleteItemEvent extends RestaurantEvent {
  final String itemId;

  const DeleteItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
