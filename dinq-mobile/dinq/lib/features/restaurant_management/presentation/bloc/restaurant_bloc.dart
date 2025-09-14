import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/restaurant/create_restaurant.dart';
import '../../domain/usecases/restaurant/delete_restaurant.dart';
import '../../domain/usecases/restaurant/get_restaurant_by_slug.dart';
import '../../domain/usecases/restaurant/get_restaurants.dart';
import '../../domain/usecases/restaurant/update_restaurant.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurants getRestaurants;
  final GetRestaurantBySlug getRestaurantBySlug;
  final CreateRestaurant createRestaurant;
  final UpdateRestaurant updateRestaurant;
  final DeleteRestaurant deleteRestaurant;

  RestaurantBloc({
    required this.getRestaurants,
    required this.getRestaurantBySlug,
    required this.createRestaurant,
    required this.updateRestaurant,
    required this.deleteRestaurant,
  }) : super(const RestaurantInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<LoadRestaurantBySlug>(_onLoadRestaurantBySlug);
    on<CreateRestaurantEvent>(_onCreateRestaurant);
    on<UpdateRestaurantEvent>(_onUpdateRestaurant);
    on<DeleteRestaurantEvent>(_onDeleteRestaurant);
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result =
        await getRestaurants(page: event.page, pageSize: event.pageSize);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurants) => emit(RestaurantsLoaded(restaurants)),
    );
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
          emit(RestaurantActionSuccess('Restaurant created successfully')),
    );
  }

  Future<void> _onUpdateRestaurant(
    UpdateRestaurantEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await updateRestaurant(event.restaurant, event.slug);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurant) =>
          emit(RestaurantActionSuccess('Restaurant updated successfully')),
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
      (success) =>
          emit(RestaurantActionSuccess('Restaurant deleted successfully')),
    );
  }
}
