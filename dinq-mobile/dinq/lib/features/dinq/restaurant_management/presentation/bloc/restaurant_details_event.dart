import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class RestaurantDetailsEvent extends Equatable {
  const RestaurantDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurantDetails extends RestaurantDetailsEvent {
  final String restaurantId;

  const LoadRestaurantDetails(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class UpdateRestaurantName extends RestaurantDetailsEvent {
  final String name;

  const UpdateRestaurantName(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateRestaurantCuisine extends RestaurantDetailsEvent {
  final String cuisine;

  const UpdateRestaurantCuisine(this.cuisine);

  @override
  List<Object?> get props => [cuisine];
}

class UpdateRestaurantLogo extends RestaurantDetailsEvent {
  final File logo;

  const UpdateRestaurantLogo(this.logo);

  @override
  List<Object?> get props => [logo];
}

class UpdateRestaurantBanner extends RestaurantDetailsEvent {
  final File banner;

  const UpdateRestaurantBanner(this.banner);

  @override
  List<Object?> get props => [banner];
}

class UpdateRestaurantDescription extends RestaurantDetailsEvent {
  final String description;

  const UpdateRestaurantDescription(this.description);

  @override
  List<Object?> get props => [description];
}

class UpdateRestaurantEmail extends RestaurantDetailsEvent {
  final String email;

  const UpdateRestaurantEmail(this.email);

  @override
  List<Object?> get props => [email];
}

class UpdateRestaurantPhone extends RestaurantDetailsEvent {
  final String phone;

  const UpdateRestaurantPhone(this.phone);

  @override
  List<Object?> get props => [phone];
}

class UpdateRestaurantLocation extends RestaurantDetailsEvent {
  final String location;

  const UpdateRestaurantLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class SaveRestaurantDetails extends RestaurantDetailsEvent {
  const SaveRestaurantDetails();
}