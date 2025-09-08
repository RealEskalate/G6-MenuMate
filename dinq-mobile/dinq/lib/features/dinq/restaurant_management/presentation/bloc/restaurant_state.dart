import 'package:equatable/equatable.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/qr.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';

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

class MenuLoaded extends RestaurantState {
  final Menu menu;

  const MenuLoaded(this.menu);

  @override
  List<Object?> get props => [menu];
}

// class CategoriesLoaded extends RestaurantState {
// class CategoriesLoaded extends RestaurantState {
//   final List<Category> categories;
//
//   const CategoriesLoaded(this.categories);
//
//   @override
//   List<Object?> get props => [categories];
// }

class QrLoaded extends RestaurantState {
  final Qr qr;

  const QrLoaded(this.qr);

  @override
  List<Object?> get props => [qr];
}

class MenuCreateLoaded extends RestaurantState {
  final dynamic menuCreateModel;

  const MenuCreateLoaded(this.menuCreateModel);

  @override
  List<Object?> get props => [menuCreateModel];
}

class MenuActionSuccess extends RestaurantActionSuccess {
  const MenuActionSuccess(super.message);
}

class ItemDetailsLoaded extends RestaurantState {
  final Item itemDetails;

  const ItemDetailsLoaded(this.itemDetails);

  @override
  List<Object?> get props => [itemDetails];
}

class ReviewsLoaded extends RestaurantState {
  final List<Review> reviews;

  const ReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class UserImagesLoaded extends RestaurantState {
  final List<String> images;

  const UserImagesLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class RestaurantError extends RestaurantState {
  final String message;

  const RestaurantError(this.message);

  @override
  List<Object?> get props => [message];
}

class RestaurantLoaded extends RestaurantState {
  final Restaurant restaurant;

  const RestaurantLoaded(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class RestaurantWithMenuLoaded extends RestaurantState {
  final Restaurant restaurant;
  final Menu menu;

  const RestaurantWithMenuLoaded(this.restaurant, this.menu);

  @override
  List<Object?> get props => [restaurant, menu];
}

class RestaurantActionSuccess extends RestaurantState {
  final String message;

  const RestaurantActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
