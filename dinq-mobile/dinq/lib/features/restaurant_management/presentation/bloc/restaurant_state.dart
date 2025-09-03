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

class RestaurantAdded extends RestaurantState {
  final Restaurant restaurant;

  const RestaurantAdded(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class ItemAdded extends RestaurantState {
  final Item item;

  const ItemAdded(this.item);

  @override
  List<Object?> get props => [item];
}

class RestaurantUpdated extends RestaurantState {
  final Restaurant restaurant;

  const RestaurantUpdated(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class MenuUpdated extends RestaurantState {
  final Menu menu;

  const MenuUpdated(this.menu);

  @override
  List<Object?> get props => [menu];
}

class ItemUpdated extends RestaurantState {
  final Item item;

  const ItemUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

class ItemDeleted extends RestaurantState {
  final bool success;

  const ItemDeleted(this.success);

  @override
  List<Object?> get props => [success];
}
