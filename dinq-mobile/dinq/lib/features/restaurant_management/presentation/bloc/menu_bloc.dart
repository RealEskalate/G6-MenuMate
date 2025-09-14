import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/menu/create_menu.dart';
import '../../domain/usecases/menu/delete_menu.dart';
import '../../domain/usecases/menu/generate_menu_qr.dart';
import '../../domain/usecases/menu/get_menu.dart';
import '../../domain/usecases/menu/publish_menu.dart';
import '../../domain/usecases/menu/update_menu.dart';
import '../../domain/usecases/menu/upload_menu.dart';
import '../../domain/usecases/restaurant/get_restaurant_by_slug.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenu getMenu;
  final CreateMenu createMenu;
  final UpdateMenu updateMenu;
  final DeleteMenu deleteMenu;
  final UploadMenu uploadMenu;
  final PublishMenu publishMenu;
  final GenerateMenuQr generateMenuQr;
  final GetRestaurantBySlug getRestaurantBySlug;

  MenuBloc({
    required this.getMenu,
    required this.createMenu,
    required this.updateMenu,
    required this.deleteMenu,
    required this.uploadMenu,
    required this.publishMenu,
    required this.generateMenuQr,
    required this.getRestaurantBySlug,
  }) : super(const MenuInitial()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<CreateMenuEvent>(_onCreateMenu);
    on<UpdateMenuEvent>(_onUpdateMenu);
    on<DeleteMenuEvent>(_onDeleteMenu);
    on<UploadMenuEvent>(_onUploadMenu);
    on<PublishMenuEvent>(_onPublishMenu);
    on<GenerateMenuQrEvent>(_onGenerateMenuQr);
  }

  Future<void> _onLoadMenu(
    LoadMenuEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    final restaurantResult = await getRestaurantBySlug(event.restaurantSlug);
    final menuResult = await getMenu(event.restaurantSlug);

    restaurantResult.fold(
      (failure) => emit(MenuError(failure.message)),
      (restaurant) => menuResult.fold(
        (failure) => emit(MenuError(failure.message)),
        (menu) => emit(MenuLoaded(menu: menu, restaurant: restaurant)),
      ),
    );
  }

  Future<void> _onCreateMenu(
    CreateMenuEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    final result = await createMenu(event.menu);
    result.fold(
      (failure) => emit(MenuError(failure.message)),
      (menu) => emit(const MenuActionSuccess('Menu created successfully')),
    );
  }

  Future<void> _onUpdateMenu(
    UpdateMenuEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    final result = await updateMenu(
      restaurantSlug: event.restaurantSlug,
      menuId: event.menuId,
      title: event.title,
      description: event.description,
    );
    result.fold(
      (failure) => emit(MenuError(failure.message)),
      (menu) => emit(const MenuActionSuccess('Menu updated successfully')),
    );
  }

  Future<void> _onDeleteMenu(
    DeleteMenuEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    final result = await deleteMenu(event.menuId);
    result.fold(
      (failure) => emit(MenuError(failure.message)),
      (_) => emit(const MenuActionSuccess('Menu deleted successfully')),
    );
  }

  Future<void> _onUploadMenu(
    UploadMenuEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    final result = await uploadMenu(event.menuFile);
    result.fold(
      (failure) => emit(MenuError(failure.message)),
      (menuCreateModel) => emit(MenuCreateLoaded(menuCreateModel)),
    );
  }

  Future<void> _onPublishMenu(
    PublishMenuEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    final result = await publishMenu(
      restaurantSlug: event.restaurantSlug,
      menuId: event.menuId,
    );
    result.fold(
      (failure) => emit(MenuError(failure.message)),
      (menu) => emit(const MenuActionSuccess('Menu published successfully')),
    );
  }

  Future<void> _onGenerateMenuQr(
    GenerateMenuQrEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
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
      (failure) => emit(MenuError(failure.message)),
      (qr) => emit(QrLoaded(qr)),
    );
  }
}
