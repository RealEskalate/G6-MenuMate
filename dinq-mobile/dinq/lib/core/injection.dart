import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../features/dinq/restaurant_management/data/datasources/restaurant_remote_data_source.dart';
import '../features/dinq/restaurant_management/data/datasources/restaurant_remote_data_source_impl.dart';
import '../features/dinq/restaurant_management/data/repositories/restaurant_repository_impl.dart';
import '../features/dinq/restaurant_management/domain/repositories/restaurant_repository.dart';
import '../features/dinq/restaurant_management/domain/usecases/create_restaurant.dart';
import '../features/dinq/restaurant_management/domain/usecases/delete_restaurant.dart';
import '../features/dinq/restaurant_management/domain/usecases/get_categories.dart';
import '../features/dinq/restaurant_management/domain/usecases/get_menu.dart';
import '../features/dinq/restaurant_management/domain/usecases/get_restaurant_by_slug.dart';
import '../features/dinq/restaurant_management/domain/usecases/get_restaurants.dart';
import '../features/dinq/restaurant_management/domain/usecases/get_reviews.dart';
import '../features/dinq/restaurant_management/domain/usecases/get_user_images.dart';
import '../features/dinq/restaurant_management/domain/usecases/update_restaurant.dart';
import '../features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
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
      getRestaurantBySlug: sl(),
      createRestaurant: sl(),
      updateRestaurant: sl(),
      deleteRestaurant: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRestaurants(sl()));
  sl.registerLazySingleton(() => GetMenu(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetReviews(sl()));
  sl.registerLazySingleton(() => GetUserImages(sl()));
  sl.registerLazySingleton(() => GetRestaurantBySlug(sl()));
  sl.registerLazySingleton(() => CreateRestaurant(sl()));
  sl.registerLazySingleton(() => UpdateRestaurant(sl()));
  sl.registerLazySingleton(() => DeleteRestaurant(sl()));

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: sl(), network: sl()),
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
