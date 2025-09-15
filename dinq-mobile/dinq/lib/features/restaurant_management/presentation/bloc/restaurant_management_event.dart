import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';

abstract class RestaurantManagementEvent extends Equatable {
  const RestaurantManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadOwnerRestaurants extends RestaurantManagementEvent {
  const LoadOwnerRestaurants();
}

class SelectRestaurant extends RestaurantManagementEvent {
  final Restaurant restaurant;

  const SelectRestaurant(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class CreateRestaurantEvent extends RestaurantManagementEvent {
  final FormData restaurantModel;

  const CreateRestaurantEvent(this.restaurantModel);

  @override
  List<Object?> get props => [restaurantModel];
}

class UpdateRestaurantEvent extends RestaurantManagementEvent {
  final FormData restaurant;
  final String slug;

  const UpdateRestaurantEvent(this.restaurant, this.slug);

  @override
  List<Object?> get props => [restaurant, slug];
}

class DeleteRestaurantEvent extends RestaurantManagementEvent {
  final String restaurantId;

  const DeleteRestaurantEvent(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class LoadMenusEvent extends RestaurantManagementEvent {}

class CreateMenuEvent extends RestaurantManagementEvent {
  final Menu menu;

  const CreateMenuEvent(this.menu);

  @override
  List<Object?> get props => [menu];
}

class UpdateMenuEvent extends RestaurantManagementEvent {
  final String menuId;
  final String? title;
  final String? description;

  const UpdateMenuEvent({
    required this.menuId,
    this.title,
    this.description,
  });

  @override
  List<Object?> get props => [menuId, title, description];
}

class DeleteMenuEvent extends RestaurantManagementEvent {
  final String menuId;

  const DeleteMenuEvent(this.menuId);

  @override
  List<Object?> get props => [menuId];
}

class PublishMenuEvent extends RestaurantManagementEvent {
  final String menuId;

  const PublishMenuEvent(this.menuId);

  @override
  List<Object?> get props => [menuId];
}
