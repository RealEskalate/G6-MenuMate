import 'package:equatable/equatable.dart';
import '../../../../restaurant_management/data/model/menu_model.dart';
import '../../../../restaurant_management/domain/entities/menu.dart';
import '../../../../restaurant_management/domain/entities/restaurant.dart';

enum MenuStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class MenuState extends Equatable {
  final MenuStatus status;
  final String? errorMessage;
  final String? slug;
  final List<MenuModel> menus;

  const MenuState({
    this.status = MenuStatus.initial,
    this.errorMessage,
    this.slug,
    this.menus = const [],
  });

  MenuState copyWith({
    MenuStatus? status,
    List<Restaurant>? restaurants,
    String? errorMessage,
    String? slug,
    List<MenuModel>? menus,
  }) {
    return MenuState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      slug: slug?? this.slug,
      menus: menus ?? this.menus
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, slug, menus];
}
