import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../restaurant_management/domain/usecases/restaurant/get_list_menus.dart';
import '../../../../restaurant_management/domain/usecases/restaurant/get_restaurants.dart';
import '../../../../restaurant_management/domain/usecases/restaurant/search_restaurants.dart';
// import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRestaurants getRestaurants;
  final SearchRestaurants searchRestaurants;
  final GetListMenus getListMenus;

  Timer? _debounce;

  HomeBloc(
      {required this.getRestaurants,
      required this.searchRestaurants,
      required this.getListMenus})
      : super(const HomeState()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<SearchQueryChanged>(_onSearchChanged);
    on<ClearSearch>(_onClearSearch);
    on<LoadMoreRestaurants>(_onLoadMoreRestaurants);
    // on<LoadListOfMenus>(_onLoadListOfMenus);
  }

  // Future<void> _onLoadListOfMenus(
  //     LoadListOfMenus event, Emitter<HomeState> emit) async {
  //   emit(state.copyWith(status: HomeStatus.loading));
  //   final params = GetListMenusParams(slug: event.slug);
  //   final result = await getListMenus(params);
  //   result.fold((failure) {
  //     emit(state.copyWith(
  //       status: HomeStatus.error,
  //       errorMessage: failure.message,
  //     ));
  //   }, (menus) {
  //     if (menus.isEmpty) {
  //       emit(state.copyWith(status: HomeStatus.empty));
  //     } else {
  //       emit(state.copyWith(status: HomeStatus.success, Menus:menus));
  //     }
  //   });
  // }
  Future<void> _onLoadMoreRestaurants(
      LoadMoreRestaurants event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    
  }

  // Load all restaurants on page load
  Future<void> _onLoadRestaurants(
      LoadRestaurants event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    final param =
        GetRestaurantsParams(page: event.page, pageSize: event.pageSize);
    final result = await getRestaurants(param);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: HomeStatus.error,
          errorMessage: failure.message,
        ));
      },
      (restaurants) {
        if (restaurants.isEmpty) {
          emit(state.copyWith(status: HomeStatus.empty));
        } else {
          emit(state.copyWith(
            status: HomeStatus.success,
            restaurants: restaurants,
          ));
        }
      },
    );
  }

  // Handle search with debounce
  Future<void> _onSearchChanged(
      SearchQueryChanged event, Emitter<HomeState> emit) async {
    // debounce inside async handler to keep emit() calls within handler's lifetime
    _debounce?.cancel();

    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(
        status: HomeStatus.success,
        restaurants: state.restaurants,
        query: '',
      ));
      return;
    }

    // wait for debounce period but keep this handler async so emits remain valid
    await Future.delayed(const Duration(milliseconds: 500));

    // if query changed while waiting, ignore (simple check)
    if (event.query.trim() != query) return;

    emit(state.copyWith(status: HomeStatus.loading, query: query));
    final params = SearchRestaurantsParams(name: query);
    final results = await searchRestaurants(params);

    if (emit.isDone) return; // safety: don't emit after handler is completed

    results.fold(
      (failure) {
        emit(state.copyWith(
          status: HomeStatus.error,
          errorMessage: failure.message,
        ));
      },
      (restaurants) {
        if (restaurants.isEmpty) {
          emit(state.copyWith(status: HomeStatus.empty, restaurants: []));
        } else {
          emit(state.copyWith(
            status: HomeStatus.success,
            restaurants: restaurants,
          ));
        }
      },
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      status: HomeStatus.success,
      restaurants: state.restaurants,
      query: '',
    ));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
