import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_menu.dart';
import '../../domain/usecases/get_restaurants.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../domain/usecases/get_user_images.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurants getRestaurants;
  final GetMenu getMenu;
  final GetCategories getCategories;
  final GetReviews getReviews;
  final GetUserimages getUserImages;

  RestaurantBloc({
    required this.getRestaurants,
    required this.getMenu,
    required this.getCategories,
    required this.getReviews,
    required this.getUserImages,
  }) : super(const RestaurantInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<LoadMenu>(_onLoadMenu);
    on<LoadCategories>(_onLoadCategories);
    on<LoadUserImages>(_onLoadUserImages);
    on<LoadReviews>(_onLoadReviews);
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await getRestaurants();
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurants) => emit(RestaurantsLoaded(restaurants)),
    );
  }

  Future<void> _onLoadMenu(
    LoadMenu event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await getMenu(event.restaurantId);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (menu) => emit(MenuLoaded(menu)),
    );
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<RestaurantState> emit,
  ) async {
    final currentState = state;
    if (currentState is MenuLoaded) {
      emit(const RestaurantLoading());
      final result = await getCategories(event.tabId);
      result.fold((failure) => emit(RestaurantError(failure.message)), (
        categories,
      ) {
        final updatedCategories = Map<String, List<dynamic>>.from(
          currentState.categories,
        );
        updatedCategories[event.tabId] = categories;
        emit(currentState.copyWith(categories: updatedCategories));
      });
    }
  }

  Future<void> _onLoadReviews(
    LoadReviews event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await getReviews(event.itemId);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (reviews) => emit(ReviewsLoaded(reviews)),
    );
  }

  Future<void> _onLoadUserImages(
    LoadUserImages event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await getUserImages(event.slug);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (images) => emit(UserImagesLoaded(images)),
    );
  }
}
