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
  final bool hasMore;

  const HomeState({
    this.status = HomeStatus.initial,
    this.restaurants = const [],
    this.errorMessage,
    this.query = '',
    this.menus = const [],
    this.hasMore=false
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Restaurant>? restaurants,
    String? errorMessage,
    String? query,
    List<Menu>? menus,
    bool? hasmore
  }) {
    return HomeState(
        status: status ?? this.status,
        restaurants: restaurants ?? this.restaurants,
        errorMessage: errorMessage ?? this.errorMessage,
        query: query ?? this.query,
        menus: menus ?? this.menus,
        hasMore: hasmore?? this.hasMore,
        );

  }

  @override
  List<Object?> get props => [status, restaurants, errorMessage, query, hasMore];
}
