import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'features/dinq/restaurant_management/data/datasources/restaurant_remote_data_source.dart';
import 'features/dinq/restaurant_management/data/datasources/restaurant_remote_data_source_impl.dart';
import 'features/dinq/restaurant_management/data/repositories/restaurant_repository_impl.dart';
import 'features/dinq/restaurant_management/domain/repositories/restaurant_repository.dart';
import 'features/dinq/restaurant_management/domain/usecases/get_user_images.dart';
import 'features/dinq/restaurant_management/domain/usecases/menu/get_menu.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/create_restaurant.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/delete_restaurant.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/get_restaurant_by_slug.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/get_restaurants.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/update_restaurant.dart';
import 'features/dinq/restaurant_management/domain/usecases/review/delete_review.dart';
import 'features/dinq/restaurant_management/domain/usecases/review/get_reviews.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'core/constants/constants.dart';
import 'core/network/network_info.dart';

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
  sl.registerLazySingleton(() => DeleteReview(sl()));
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
  // External
  // Configure Dio with base options so injected callers reuse same client
  sl.registerLazySingleton(() => Dio(BaseOptions(baseUrl: baseUrl)));
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
