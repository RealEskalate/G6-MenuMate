import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_endpoints.dart';
import 'core/network/auth_interceptor.dart';
import 'core/network/network_info.dart';
import 'core/network/token_manager.dart';
import 'features/auth/data/datasources/user_local_data_source.dart';
import 'features/auth/data/datasources/user_local_data_source_impl.dart';
import 'features/auth/data/datasources/user_remote_data_source.dart';
import 'features/auth/data/datasources/user_remote_data_source_impl.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/domain/repositories/user_repository.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/domain/usecases/clear_favorites_usecase.dart';
import 'features/auth/domain/usecases/delete_favorite_id.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'features/auth/domain/usecases/get_favorite_restaurant_ids_usecase.dart';
import 'features/auth/domain/usecases/get_google_redirect_usecase.dart';
import 'features/auth/domain/usecases/handle_google_callback_usecase.dart';
import 'features/auth/domain/usecases/login_user_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_user_usecase.dart';
import 'features/auth/domain/usecases/resend_otp_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/save_favorite_restaurant_ids_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/domain/usecases/verify_email_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/presentation/bloc/user_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/restaurant_management/presentation/bloc/menu_bloc.dart';
import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/restaurant_management/presentation/bloc/review_bloc.dart';
import 'features/restaurant_management/data/datasources/menu/menu_remote_data_source.dart';
import 'features/restaurant_management/data/datasources/menu/menu_remote_data_source_impl.dart';
import 'features/restaurant_management/data/datasources/restaurant/restaurant_remote_data_source_restaurant.dart';
import 'features/restaurant_management/data/datasources/restaurant/restaurant_remote_data_source_restaurant_impl.dart';
import 'features/restaurant_management/data/datasources/review/review_remote_data_source.dart';
import 'features/restaurant_management/data/datasources/review/review_remote_data_source_impl.dart';
import 'features/restaurant_management/data/repositories/menu_repository_impl.dart';
import 'features/restaurant_management/data/repositories/restaurant_repository_impl.dart';
import 'features/restaurant_management/data/repositories/review_repository_impl.dart';
import 'features/restaurant_management/domain/repositories/menu_repository.dart';
import 'features/restaurant_management/domain/repositories/restaurant_repository.dart';
import 'features/restaurant_management/domain/repositories/review_repository.dart';
import 'features/restaurant_management/domain/usecases/menu/create_menu.dart';
import 'features/restaurant_management/domain/usecases/menu/delete_menu.dart';
import 'features/restaurant_management/domain/usecases/menu/generate_menu_qr.dart';
import 'features/restaurant_management/domain/usecases/menu/get_menu.dart';
import 'features/restaurant_management/domain/usecases/menu/publish_menu.dart';
import 'features/restaurant_management/domain/usecases/menu/update_menu.dart';
import 'features/restaurant_management/domain/usecases/menu/upload_menu.dart';
import 'features/restaurant_management/domain/usecases/restaurant/create_restaurant.dart';
import 'features/restaurant_management/domain/usecases/restaurant/delete_restaurant.dart';
import 'features/restaurant_management/domain/usecases/restaurant/get_restaurant_by_slug.dart';
import 'features/restaurant_management/domain/usecases/restaurant/get_restaurants.dart';
import 'features/restaurant_management/domain/usecases/restaurant/update_restaurant.dart';
import 'features/restaurant_management/domain/usecases/review/delete_review.dart';
import 'features/restaurant_management/domain/usecases/review/get_reviews.dart';
import 'features/restaurant_management/domain/usecases/review/get_user_images.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Load environment variables and register dotenv for DI
  await dotenv.load(fileName: '.env');
  sl.registerLazySingleton<DotEnv>(() => dotenv);
  // BLoC
  // BLoC registrations are done after usecases to ensure dependencies are available
  // BLoC for registration flow
  // (UserBloc registration moved down after usecase registrations)
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

  // Now register BLoCs (after usecases)
  sl.registerFactory(
    () => RestaurantBloc(
      getRestaurants: sl(),
      getRestaurantBySlug: sl(),
      createRestaurant: sl(),
      updateRestaurant: sl(),
      deleteRestaurant: sl(),
    ),
  );

  sl.registerFactory(
    () => MenuBloc(
      getMenu: sl(),
      createMenu: sl(),
      updateMenu: sl(),
      deleteMenu: sl(),
      uploadMenu: sl(),
      publishMenu: sl(),
      generateMenuQr: sl(),
      getRestaurantBySlug: sl(),
    ),
  );

  sl.registerFactory(
    () => ReviewBloc(
      getReviews: sl(),
      getUserImages: sl(),
    ),
  );

  // BLoC for user flows (register/login/profile/google auth/etc)
  sl.registerFactory(
    () => UserBloc(
      deleteFavoriteId: sl(),
      registerUser: sl(),
      loginUser: sl(),
      verifyOtp: sl(),
      resendOtp: sl(),
      verifyEmail: sl(),
      forgotPassword: sl(),
      resetPassword: sl(),
      changePassword: sl(),
      updateProfile: sl(),
      getGoogleRedirect: sl(),
      handleGoogleCallback: sl(),
      logout: sl(),
      getCachedUser: sl(),
      saveFavoriteRestaurantIds: sl(),
      getFavoriteRestaurantIds: sl(),
      clearFavorites: sl(),
      userRepository: sl(),
    ),
  );

  // BLoC for authentication
  sl.registerFactory(
    () => AuthBloc(
      registerUser: sl(),
      loginUser: sl(),
      logout: sl(),
      getCachedUser: sl(),
      userRepository: sl(),
    ),
  );

  // -- Auth (User) use cases (registered before UserBloc)
  sl.registerLazySingleton(() => DeleteFavoriteId(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetGoogleRedirectUseCase(sl()));
  sl.registerLazySingleton(() => HandleGoogleCallbackUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => SaveFavoriteRestaurantIdsUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteRestaurantIdsUseCase(sl()));
  sl.registerLazySingleton(() => ClearFavoritesUseCase(sl()));
  // -- Auth (User) feature registrations
  // Data source and repository
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(dio: sl()));

  // SharedPreferences and local user datasource (used by UserRepository)
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSourceImpl(prefs: sl()));

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        remoteDataSource: sl(),
        network: sl(),
        tokenManager: sl(),
        userLocalDataSource: sl(),
      ));
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
  // SharedPreferences for local caching
  // SharedPreferences instance will be created and registered later once core is configured

  // Configure Dio with base options so injected callers reuse same client
  // Use ApiEndpoints.root as the base URL provider
  final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.root));

  // dedicated Dio used for refresh calls to avoid recursion
  final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.root));

  // register secure storage backed TokenManager
  sl.registerLazySingleton(
      () => TokenManager(secureStorage: const FlutterSecureStorage()));

  // register refreshDio and AuthInterceptor
  // register main Dio explicitly
  sl.registerLazySingleton<Dio>(() => dio);
  // register a separate named Dio instance for refresh calls
  sl.registerLazySingleton<Dio>(() => refreshDio, instanceName: 'refreshDio');

  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(
      tokenManager: sl(), refreshDio: sl<Dio>(instanceName: 'refreshDio')));
  // add interceptor to main dio
  dio.interceptors.add(sl<AuthInterceptor>());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // SharedPreferences and local user datasource
  // (already registered above)
}
