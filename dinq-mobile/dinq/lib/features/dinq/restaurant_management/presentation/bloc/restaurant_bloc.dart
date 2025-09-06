import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/menu/create_menu.dart';
import '../../domain/usecases/menu/delete_menu.dart';
import '../../domain/usecases/menu/generate_menu_qr.dart';
import '../../domain/usecases/menu/get_menu.dart';
import '../../domain/usecases/menu/publish_menu.dart';
import '../../domain/usecases/menu/update_menu.dart';
import '../../domain/usecases/menu/upload_menu.dart';
import '../../domain/usecases/restaurant/create_restaurant.dart';
import '../../domain/usecases/restaurant/delete_restaurant.dart';
import '../../domain/usecases/restaurant/get_restaurant_by_slug.dart';
import '../../domain/usecases/restaurant/get_restaurants.dart';
import '../../domain/usecases/restaurant/update_restaurant.dart';
// import '../../domain/usecases/review/delete_review.dart';
import '../../domain/usecases/review/get_reviews.dart';
import '../../domain/usecases/review/get_user_images.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurants getRestaurants;
  final GetMenu getMenu;
  final CreateMenu createMenu;
  final UpdateMenu updateMenu;
  final DeleteMenu deleteMenu;
  final UploadMenu uploadMenu;
  final PublishMenu publishMenu;
  final GenerateMenuQr generateMenuQr;
  // categories usecase not implemented; remove incorrect field
  final GetReviews getReviews;
// <<<<<<< HEAD:dinq-mobile/dinq/lib/features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart
  final GetUserImages getUserImages;
  final GetRestaurantBySlug getRestaurantBySlug;
  final CreateRestaurant createRestaurant;
  final UpdateRestaurant updateRestaurant;
  final DeleteRestaurant deleteRestaurant;

  // final GetUserImages getUserImages;
// >>>>>>> m-feature/restaurant-menu:dinq-mobile/dinq/lib/features/restaurant_management/presentation/bloc/restaurant_bloc.dart

  RestaurantBloc({
    required this.getRestaurants,
    required this.getMenu,
    required this.createMenu,
    required this.updateMenu,
    required this.deleteMenu,
    required this.uploadMenu,
    required this.publishMenu,
    required this.generateMenuQr,
    required this.getReviews,
    required this.getUserImages,
    required this.getRestaurantBySlug,
    required this.createRestaurant,
    required this.updateRestaurant,
    required this.deleteRestaurant,
  }) : super(const RestaurantInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<LoadMenu>(_onLoadMenu);
    on<CreateMenuEvent>(_onCreateMenu);
    on<UpdateMenuEvent>(_onUpdateMenu);
    on<DeleteMenuEvent>(_onDeleteMenu);
    on<UploadMenuEvent>(_onUploadMenu);
    on<PublishMenuEvent>(_onPublishMenu);
    on<GenerateMenuQrEvent>(_onGenerateMenuQr);
    // on<LoadCategories>(_onLoadCategories);
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
      (restaurant) => emit(
        const RestaurantActionSuccess('Restaurant created successfully'),
      ),
    );
  }

  Future<void> _onCreateMenu(
    CreateMenuEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await createMenu(event.menu);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (menu) => emit(const MenuActionSuccess('Menu created successfully')),
    );
  }

  Future<void> _onUpdateMenu(
    UpdateMenuEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await updateMenu(
      restaurantSlug: event.restaurantSlug,
      menuId: event.menuId,
      title: event.title,
      description: event.description,
    );
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (menu) => emit(const MenuActionSuccess('Menu updated successfully')),
    );
  }

  Future<void> _onDeleteMenu(
    DeleteMenuEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await deleteMenu(event.menuId);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (_) => emit(const MenuActionSuccess('Menu deleted successfully')),
    );
  }

  Future<void> _onUploadMenu(
    UploadMenuEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await uploadMenu(event.menuFile);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (menu) => emit(const MenuActionSuccess('Menu uploaded successfully')),
    );
  }

  Future<void> _onPublishMenu(
    PublishMenuEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await publishMenu(
      restaurantSlug: event.restaurantSlug,
      menuId: event.menuId,
    );
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (menu) => emit(const MenuActionSuccess('Menu published successfully')),
    );
  }

  Future<void> _onGenerateMenuQr(
    GenerateMenuQrEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    final result = await generateMenuQr(
      restaurantSlug: event.restaurantSlug,
      menuId: event.menuId,
      size: event.size,
      quality: event.quality,
      includeLabel: event.includeLabel,
      backgroundColor: event.backgroundColor,
      foregroundColor: event.foregroundColor,
      gradientFrom: event.gradientFrom,
      gradientTo: event.gradientTo,
      gradientDirection: event.gradientDirection,
      logo: event.logo,
      logoSizePercent: event.logoSizePercent,
      margin: event.margin,
      labelText: event.labelText,
      labelColor: event.labelColor,
      labelFontSize: event.labelFontSize,
      labelFontUrl: event.labelFontUrl,
    );
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (qr) => emit(QrLoaded(qr)),
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
      (restaurant) => emit(
        const RestaurantActionSuccess('Restaurant updated successfully'),
      ),
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
    final result = await getRestaurants(
      page: event.page,
      pageSize: event.pageSize,
    );
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

  // Future<void> _onLoadCategories(
  //   LoadCategories event,
  //   Emitter<RestaurantState> emit,
  // ) async {
  //   final currentState = state;
  //   if (currentState is MenuLoaded) {
  //     emit(const RestaurantLoading());
  //     final result = await getCategories(event.tabId);
  //     result.fold((failure) => emit(RestaurantError(failure.message)), (
  //       categories,
  //     ) {
  //       final updatedCategories = Map<String, List<dynamic>>.from(
  //         currentState.categories,
  //       );
  //       updatedCategories[event.tabId] = categories;
  //       emit(currentState.copyWith(categories: updatedCategories));
  //     });
  //   }
  // }

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
