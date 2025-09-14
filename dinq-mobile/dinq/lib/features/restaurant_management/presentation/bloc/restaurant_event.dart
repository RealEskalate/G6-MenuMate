import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends RestaurantEvent {
  final int page;
  final int pageSize;

  const LoadRestaurants({required this.page, required this.pageSize});
}

class LoadRestaurantBySlug extends RestaurantEvent {
  final String slug;

  const LoadRestaurantBySlug(this.slug);

  @override
  List<Object?> get props => [slug];
}

class CreateRestaurantEvent extends RestaurantEvent {
  final FormData restaurantModel;

  const CreateRestaurantEvent(this.restaurantModel);

  @override
  List<Object?> get props => [restaurantModel];
}

class UpdateRestaurantEvent extends RestaurantEvent {
  final FormData restaurant;
  final String slug;

  const UpdateRestaurantEvent(this.restaurant, this.slug);

  @override
  List<Object?> get props => [restaurant, slug];
}

class DeleteRestaurantEvent extends RestaurantEvent {
  final String restaurantId;

  const DeleteRestaurantEvent(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}
