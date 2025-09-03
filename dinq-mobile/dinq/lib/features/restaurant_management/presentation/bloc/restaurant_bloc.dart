import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_menu.dart';
import '../../domain/usecases/get_restaurants.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../domain/usecases/get_user_images.dart';
import '../../domain/usecases/get_restaurant_by_slug.dart';
import '../../domain/usecases/create_restaurant.dart';
import '../../domain/usecases/update_restaurant.dart';
import '../../domain/usecases/delete_restaurant.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurants getRestaurants;
  final GetMenu getMenu;
  final GetCategories getCategories;
  final GetReviews getReviews;
  final GetUserimages getUserImages;
  final GetRestaurantBySlug getRestaurantBySlug;
  final CreateRestaurant createRestaurant;
  final UpdateRestaurant updateRestaurant;
  final DeleteRestaurant deleteRestaurant;

  RestaurantBloc({
    required this.getRestaurants,
    required this.getMenu,
    required this.getCategories,
    required this.getReviews,
    required this.getUserImages,
    required this.getRestaurantBySlug,
    required this.createRestaurant,
    required this.updateRestaurant,
    required this.deleteRestaurant,
  }) : super(const RestaurantInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<LoadMenu>(_onLoadMenu);
    on<LoadCategories>(_onLoadCategories);
    on<LoadUserImages>(_onLoadUserImages);
    on<LoadReviews>(_onLoadReviews);
    on<LoadRestaurantBySlug>(_onLoadRestaurantBySlug);
    on<CreateRestaurantEvent>(_onCreateRestaurant);
    on<UpdateRestaurantEvent>(_onUpdateRestaurant);
    on<DeleteRestaurantEvent>(_onDeleteRestaurant);
  }

  Future<void> _onLoadRestaurantBySlug(
    LoadRestaurantBySlug event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await getRestaurantBySlug(event.slug);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurant) => emit(RestaurantLoaded(restaurant)),
    );
  }

  Future<void> _onCreateRestaurant(
    CreateRestaurantEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await createRestaurant(event.restaurantModel);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurant) =>
          emit(const RestaurantActionSuccess('Restaurant created successfully')),
    );
  }

  Future<void> _onUpdateRestaurant(
    UpdateRestaurantEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await updateRestaurant(event.restaurantModel, event.slug);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurant) =>
          emit(const RestaurantActionSuccess('Restaurant updated successfully')),
    );
  }

  Future<void> _onDeleteRestaurant(
    DeleteRestaurantEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await deleteRestaurant(event.restaurantId);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (_) => emit(
        const RestaurantActionSuccess('Restaurant deleted successfully'),
      ),
    );
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await getRestaurants(page:event.page, pageSize:event.pageSize);
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
