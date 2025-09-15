import 'package:equatable/equatable.dart';

import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';

abstract class RestaurantManagementState extends Equatable {
  const RestaurantManagementState();

  @override
  List<Object?> get props => [];
}

class RestaurantManagementInitial extends RestaurantManagementState {
  const RestaurantManagementInitial();
}

class RestaurantManagementLoading extends RestaurantManagementState {
  const RestaurantManagementLoading();
}

class OwnerRestaurantsLoaded extends RestaurantManagementState {
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;

  const OwnerRestaurantsLoaded(this.restaurants, {this.selectedRestaurant});

  @override
  List<Object?> get props => [restaurants, selectedRestaurant];
}

class RestaurantSelected extends RestaurantManagementState {
  final Restaurant selectedRestaurant;
  final List<Menu> menus;

  const RestaurantSelected(this.selectedRestaurant, this.menus);

  @override
  List<Object?> get props => [selectedRestaurant, menus];
}

class RestaurantManagementError extends RestaurantManagementState {
  final String message;

  const RestaurantManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

class RestaurantManagementSuccess extends RestaurantManagementState {
  final String message;

  const RestaurantManagementSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RestaurantCreated extends RestaurantManagementState {
  final Restaurant restaurant;

  const RestaurantCreated(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class MenusLoaded extends RestaurantManagementState {
  final List<Menu> menus;

  const MenusLoaded(this.menus);

  @override
  List<Object?> get props => [menus];
}
