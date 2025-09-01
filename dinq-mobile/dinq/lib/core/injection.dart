import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../features/restaurant_management/data/datasources/restaurant_remote_data_source.dart';
import '../features/restaurant_management/data/datasources/restaurant_remote_data_source_impl.dart';
import '../features/restaurant_management/data/repositories/restaurant_repository_impl.dart';
import '../features/restaurant_management/domain/repositories/restaurant_repository.dart';
import '../features/restaurant_management/domain/usecases/get_categories.dart';
import '../features/restaurant_management/domain/usecases/get_menu.dart';
import '../features/restaurant_management/domain/usecases/get_restaurants.dart';
import '../features/restaurant_management/domain/usecases/get_reviews.dart';
import '../features/restaurant_management/domain/usecases/get_user_images.dart';
import '../features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(
    () => RestaurantBloc(
      getRestaurants: sl(),
      getMenu: sl(),
      getCategories: sl(),
      getReviews: sl(),
      getUserImages: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRestaurants(sl()));
  sl.registerLazySingleton(() => GetMenu(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetReviews(sl()));
  sl.registerLazySingleton(() => GetUserimages(sl()));

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(
      remoteDataSource: sl(),
      network: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(dio: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}
