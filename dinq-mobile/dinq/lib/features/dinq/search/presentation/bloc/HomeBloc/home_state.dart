import 'package:equatable/equatable.dart';
import '../../../../restaurant_management/domain/entities/menu.dart';
import '../../../../restaurant_management/domain/entities/restaurant.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Restaurant> restaurants;
  final String? errorMessage;
  final String query;
  final List<Menu> menus;

  const HomeState({
    this.status = HomeStatus.initial,
    this.restaurants = const [],
    this.errorMessage,
    this.query = '',
    this.menus = const [],
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Restaurant>? restaurants,
    String? errorMessage,
    String? query,
    List<Menu>? menus,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      menus: menus ?? this.menus
    );
  }

  @override
  List<Object?> get props => [status, restaurants, errorMessage, query];
}
