import 'package:equatable/equatable.dart';

import '../../domain/entities/restaurant.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

class RestaurantLoading extends RestaurantState {
  const RestaurantLoading();
}

class RestaurantsLoaded extends RestaurantState {
  final List<Restaurant> restaurants;

  const RestaurantsLoaded(this.restaurants);

  @override
  List<Object?> get props => [restaurants];
}

class RestaurantLoaded extends RestaurantState {
  final Restaurant restaurant;

  const RestaurantLoaded(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class RestaurantActionSuccess extends RestaurantState {
  final String message;

  const RestaurantActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RestaurantError extends RestaurantState {
  final String message;

  const RestaurantError(this.message);

  @override
  List<Object?> get props => [message];
}
