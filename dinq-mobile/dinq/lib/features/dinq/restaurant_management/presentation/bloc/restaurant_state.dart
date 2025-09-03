import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
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
  final Map<String, List<dynamic>> categories;

  const MenuLoaded(this.menu, {this.categories = const {}});

  MenuLoaded copyWith({Menu? menu, Map<String, List<dynamic>>? categories}) {
    return MenuLoaded(
      menu ?? this.menu,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [menu, categories];
}

class CategoriesLoaded extends RestaurantState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
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


class RestaurantActionSuccess extends RestaurantState {
  final String message;

  const RestaurantActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
