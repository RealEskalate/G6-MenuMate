import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/network/api_endpoints.dart';
import 'core/network/token_manager.dart';
import 'core/network/auth_interceptor.dart';
import 'core/network/network_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/dinq/restaurant_management/data/datasources/menu/menu_remote_data_source.dart';
import 'features/dinq/restaurant_management/data/datasources/menu/menu_remote_data_source_impl.dart';
import 'features/dinq/restaurant_management/data/datasources/restaurant/restaurant_remote_data_source_restaurant.dart';
import 'features/dinq/restaurant_management/data/datasources/restaurant/restaurant_remote_data_source_restaurant_impl.dart';
import 'features/dinq/restaurant_management/data/datasources/review/review_remote_data_source.dart';
import 'features/dinq/restaurant_management/data/datasources/review/review_remote_data_source_impl.dart';
import 'features/dinq/restaurant_management/data/repositories/menu_repository_impl.dart';
import 'features/dinq/restaurant_management/data/repositories/restaurant_repository_impl.dart';
import 'features/dinq/restaurant_management/data/repositories/review_repository_impl.dart';
import 'features/dinq/restaurant_management/domain/repositories/menu_repository.dart';
import 'features/dinq/restaurant_management/domain/repositories/restaurant_repository.dart';
import 'features/dinq/restaurant_management/domain/repositories/review_repository.dart';
import 'features/dinq/restaurant_management/domain/usecases/menu/create_menu.dart';
import 'features/dinq/restaurant_management/domain/usecases/menu/delete_menu.dart';
import 'features/dinq/restaurant_management/domain/usecases/menu/generate_menu_qr.dart';
import 'features/dinq/restaurant_management/domain/usecases/menu/get_menu.dart';
import 'features/dinq/restaurant_management/domain/usecases/menu/publish_menu.dart';
import 'features/dinq/restaurant_management/domain/usecases/menu/update_menu.dart';
import 'features/dinq/restaurant_management/domain/usecases/menu/upload_menu.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/create_restaurant.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/delete_restaurant.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/get_restaurant_by_slug.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/get_restaurants.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/update_restaurant.dart';
import 'features/dinq/restaurant_management/domain/usecases/review/delete_review.dart';
import 'features/dinq/restaurant_management/domain/usecases/review/get_reviews.dart';
import 'features/dinq/restaurant_management/domain/usecases/review/get_user_images.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/dinq/auth/presentation/bloc/user_bloc.dart';
import 'features/dinq/auth/domain/usecases/user/register_user_usecase.dart';
import 'features/dinq/auth/domain/usecases/user/login_user_usecase.dart';
import 'features/dinq/auth/data/datasources/user_remote_data_source.dart';
import 'features/dinq/auth/data/datasources/user_remote_data_source_impl.dart';
import 'features/dinq/auth/data/repositories/user_repository_impl.dart';
import 'features/dinq/auth/domain/repositories/user_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(
    () => RestaurantBloc(
      getRestaurants: sl(),
      getMenu: sl(),
      createMenu: sl(),
      updateMenu: sl(),
      deleteMenu: sl(),
      uploadMenu: sl(),
      publishMenu: sl(),
      generateMenuQr: sl(),
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
  sl.registerLazySingleton(() => CreateMenu(sl()));
  sl.registerLazySingleton(() => UpdateMenu(sl()));
  sl.registerLazySingleton(() => DeleteMenu(sl()));
  sl.registerLazySingleton(() => UploadMenu(sl()));
  sl.registerLazySingleton(() => PublishMenu(sl()));
  sl.registerLazySingleton(() => GenerateMenuQr(sl()));
  sl.registerLazySingleton(() => DeleteReview(sl()));
  sl.registerLazySingleton(() => GetReviews(sl()));
  sl.registerLazySingleton(() => GetUserImages(sl()));
  sl.registerLazySingleton(() => GetRestaurantBySlug(sl()));
  sl.registerLazySingleton(() => CreateRestaurant(sl()));
  sl.registerLazySingleton(() => UpdateRestaurant(sl()));
  sl.registerLazySingleton(() => DeleteRestaurant(sl()));

  // -- Auth (User) feature registrations
  // Data source and repository
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(dio: sl()));

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        remoteDataSource: sl(),
        network: sl(),
        tokenManager: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));

  // BLoC for registration flow
  sl.registerFactory(() => UserBloc(registerUser: sl()));

  // Repository
  // Data sources
  sl.registerLazySingleton<MenuRemoteDataSource>(
      () => MenuRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
      () => RestaurantRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<ReviewRemoteDataSource>(
      () => ReviewRemoteDataSourceImpl(dio: sl()));

  // Repository implementation (single impl that satisfies multiple interfaces)
  sl.registerLazySingleton<RestaurantRepository>(() => RestaurantRepositoryImpl(
        restRemoteDataSource: sl(),
        network: sl(),
      ));

  sl.registerLazySingleton<MenuRepository>(() => MenuRepositoryImpl(
        menuRemoteDataSource: sl(),
        network: sl(),
      ));

  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(
        reviewRemoteDataSource: sl(),
        network: sl(),
      ));

  // Bind interfaces to the same impl

  // Core
  // External
  // Configure Dio with base options so injected callers reuse same client
  // Use ApiEndpoints.root as the base URL provider
  final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.root));

  // dedicated Dio used for refresh calls to avoid recursion
  final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.root));

  // register secure storage backed TokenManager
  sl.registerLazySingleton(
      () => TokenManager(secureStorage: const FlutterSecureStorage()));

  // register refreshDio and AuthInterceptor
  sl.registerLazySingleton(() => refreshDio);
  sl.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(tokenManager: sl(), refreshDio: sl()));

  // add interceptor to main dio
  dio.interceptors.add(sl<AuthInterceptor>());

  sl.registerLazySingleton(() => dio);
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
