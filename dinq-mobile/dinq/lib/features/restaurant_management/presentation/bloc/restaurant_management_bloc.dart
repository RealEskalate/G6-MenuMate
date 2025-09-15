import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/usecases/menu/create_menu.dart';
import '../../domain/usecases/menu/delete_menu.dart';
import '../../domain/usecases/menu/get_menu.dart';
import '../../domain/usecases/menu/publish_menu.dart';
import '../../domain/usecases/menu/update_menu.dart';
import '../../domain/usecases/restaurant/create_restaurant.dart';
import '../../domain/usecases/restaurant/delete_restaurant.dart';
import '../../domain/usecases/restaurant/get_owner_restaurants.dart';
import '../../domain/usecases/restaurant/get_restaurant_by_slug.dart';
import '../../domain/usecases/restaurant/update_restaurant.dart';
import 'restaurant_management_event.dart';
import 'restaurant_management_state.dart';

class RestaurantManagementBloc
    extends Bloc<RestaurantManagementEvent, RestaurantManagementState> {
  final GetOwnerRestaurants getOwnerRestaurants;
  final GetRestaurantBySlug getRestaurantBySlug;
  final CreateRestaurant createRestaurant;
  final UpdateRestaurant updateRestaurant;
  final DeleteRestaurant deleteRestaurant;
  final GetMenu getMenu;
  final CreateMenu createMenu;
  final UpdateMenu updateMenu;
  final DeleteMenu deleteMenu;
  final PublishMenu publishMenu;

  Restaurant? _selectedRestaurant;
  List<Menu> _currentMenus = [];

  RestaurantManagementBloc({
    required this.getOwnerRestaurants,
    required this.getRestaurantBySlug,
    required this.createRestaurant,
    required this.updateRestaurant,
    required this.deleteRestaurant,
    required this.getMenu,
    required this.createMenu,
    required this.updateMenu,
    required this.deleteMenu,
    required this.publishMenu,
  }) : super(const RestaurantManagementInitial()) {
    on<LoadOwnerRestaurants>(_onLoadOwnerRestaurants);
    on<SelectRestaurant>(_onSelectRestaurant);
    on<CreateRestaurantEvent>(_onCreateRestaurant);
    on<UpdateRestaurantEvent>(_onUpdateRestaurant);
    on<DeleteRestaurantEvent>(_onDeleteRestaurant);
    on<LoadMenusEvent>(_onLoadMenus);
    on<CreateMenuEvent>(_onCreateMenu);
    on<UpdateMenuEvent>(_onUpdateMenu);
    on<DeleteMenuEvent>(_onDeleteMenu);
    on<PublishMenuEvent>(_onPublishMenu);
  }

  Future<void> _onLoadOwnerRestaurants(
    LoadOwnerRestaurants event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    emit(const RestaurantManagementLoading());
    final result = await getOwnerRestaurants();
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (restaurants) => emit(OwnerRestaurantsLoaded(
        restaurants,
        selectedRestaurant: _selectedRestaurant,
      )),
    );
  }

  Future<void> _onSelectRestaurant(
    SelectRestaurant event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    _selectedRestaurant = event.restaurant;
    emit(const RestaurantManagementLoading());

    // Load menus for the selected restaurant
    final menuResult = await getMenu(event.restaurant.slug);
    menuResult.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (menus) {
        _currentMenus = [menus];
        emit(RestaurantSelected(event.restaurant, [menus]));
      },
    );
  }

  Future<void> _onCreateRestaurant(
    CreateRestaurantEvent event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    emit(const RestaurantManagementLoading());
    final result = await createRestaurant(event.restaurantModel);
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (restaurant) {
        emit(RestaurantCreated(restaurant));
        // Reload owner restaurants to include the new one
        add(const LoadOwnerRestaurants());
      },
    );
  }

  Future<void> _onUpdateRestaurant(
    UpdateRestaurantEvent event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    emit(const RestaurantManagementLoading());
    final result = await updateRestaurant(event.restaurant, event.slug);
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (restaurant) {
        emit(const RestaurantManagementSuccess(
            'Restaurant updated successfully'));
        // Reload owner restaurants to reflect changes
        add(const LoadOwnerRestaurants());
      },
    );
  }

  Future<void> _onDeleteRestaurant(
    DeleteRestaurantEvent event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    emit(const RestaurantManagementLoading());
    final result = await deleteRestaurant(event.restaurantId);
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (success) {
        emit(const RestaurantManagementSuccess(
            'Restaurant deleted successfully'));
        // Clear selection if deleted restaurant was selected
        if (_selectedRestaurant?.id == event.restaurantId) {
          _selectedRestaurant = null;
          _currentMenus = [];
        }
        // Reload owner restaurants
        add(const LoadOwnerRestaurants());
      },
    );
  }

  Future<void> _onLoadMenus(
    LoadMenusEvent event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    if (_selectedRestaurant == null) {
      emit(const RestaurantManagementError('No restaurant selected'));
      return;
    }

    emit(const RestaurantManagementLoading());
    final result = await getMenu(_selectedRestaurant!.slug);
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (menus) {
        _currentMenus = [menus];
        emit(MenusLoaded([menus]));
      },
    );
  }

  Future<void> _onCreateMenu(
    CreateMenuEvent event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    if (_selectedRestaurant == null) {
      emit(const RestaurantManagementError('No restaurant selected'));
      return;
    }

    emit(const RestaurantManagementLoading());
    final result = await createMenu(event.menu);
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (menu) {
        emit(const RestaurantManagementSuccess('Menu created successfully'));
        // Reload menus
        add(LoadMenusEvent());
      },
    );
  }

  Future<void> _onUpdateMenu(
    UpdateMenuEvent event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    if (_selectedRestaurant == null) {
      emit(const RestaurantManagementError('No restaurant selected'));
      return;
    }

    emit(const RestaurantManagementLoading());
    final result = await updateMenu(
      restaurantSlug: _selectedRestaurant!.slug,
      menuId: event.menuId,
      title: event.title,
      description: event.description,
    );
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (menu) {
        emit(const RestaurantManagementSuccess('Menu updated successfully'));
        // Reload menus
        add(LoadMenusEvent());
      },
    );
  }

  Future<void> _onDeleteMenu(
    DeleteMenuEvent event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    emit(const RestaurantManagementLoading());
    final result = await deleteMenu(event.menuId);
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (success) {
        emit(const RestaurantManagementSuccess('Menu deleted successfully'));
        // Reload menus
        add(LoadMenusEvent());
      },
    );
  }

  Future<void> _onPublishMenu(
    PublishMenuEvent event,
    Emitter<RestaurantManagementState> emit,
  ) async {
    if (_selectedRestaurant == null) {
      emit(const RestaurantManagementError('No restaurant selected'));
      return;
    }

    emit(const RestaurantManagementLoading());
    final result = await publishMenu(
        restaurantSlug: _selectedRestaurant!.slug, menuId: event.menuId);
    result.fold(
      (failure) => emit(RestaurantManagementError(failure.message)),
      (success) {
        emit(const RestaurantManagementSuccess('Menu published successfully'));
        // Reload menus
        add(LoadMenusEvent());
      },
    );
  }

  // Getters for accessing current state
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  List<Menu> get currentMenus => _currentMenus;
}
