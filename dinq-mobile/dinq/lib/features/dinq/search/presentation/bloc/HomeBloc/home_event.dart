import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends HomeEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMoreRestaurants extends HomeEvent {
  List<Object?> get props => [];
}

class LoadListOfMenus extends HomeEvent {
  final String slug;
  const LoadListOfMenus(this.slug);
  @override
  List<Object?> get props => [slug];
}

class ClearSearch extends HomeEvent {}

class LoadRestaurants extends HomeEvent {
  final int page;
  final int pageSize;

  const LoadRestaurants({required this.page, required this.pageSize});
  List<Object?> get props => [page, pageSize];
}
