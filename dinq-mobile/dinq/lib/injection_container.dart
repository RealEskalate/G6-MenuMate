import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constants/constants.dart';
import 'core/network/network_info.dart';
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
import 'features/dinq/user/data/datasources/user_remote_data_source.dart';
import 'features/dinq/user/data/datasources/user_remote_data_source_impl.dart';
import 'features/dinq/user/data/datasources/user_local_data_source.dart';
import 'features/dinq/user/data/datasources/user_local_data_source_impl.dart';
import 'features/dinq/user/data/repositories/user_repository_impl.dart';
import 'features/dinq/user/domain/repositories/user_repository.dart';
import 'features/dinq/user/domain/usecases/user/change_password_usecase.dart';
import 'features/dinq/user/domain/usecases/user/forgot_password_usecase.dart';
import 'features/dinq/user/domain/usecases/user/get_google_redirect_usecase.dart';
import 'features/dinq/user/domain/usecases/user/handle_google_callback_usecase.dart';
import 'features/dinq/user/domain/usecases/user/login_user_usecase.dart';
import 'features/dinq/user/domain/usecases/user/logout_usecase.dart';
import 'features/dinq/user/domain/usecases/user/register_user_usecase.dart';
import 'features/dinq/user/domain/usecases/user/resend_otp_usecase.dart';
import 'features/dinq/user/domain/usecases/user/reset_password_usecase.dart';
import 'features/dinq/user/domain/usecases/user/update_profile_usecase.dart';
import 'features/dinq/user/domain/usecases/user/verify_email_usecase.dart';
import 'features/dinq/user/domain/usecases/user/verify_otp_usecase.dart';
import 'features/dinq/user/presentation/bloc/user_bloc.dart';

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

  // user block
  sl.registerFactory(() => UserBloc(registerUser: sl()));
  // Use cases
  sl.registerLazySingleton(() => GetRestaurants(sl()));
  sl.registerLazySingleton(() => GetMenu(sl()));
  sl.registerLazySingleton(() => DeleteReview(sl()));
  sl.registerLazySingleton(() => GetReviews(sl()));
  sl.registerLazySingleton(() => GetUserimages(sl()));
  sl.registerLazySingleton(() => GetRestaurantBySlug(sl()));
  sl.registerLazySingleton(() => CreateRestaurant(sl()));
  sl.registerLazySingleton(() => UpdateRestaurant(sl()));
  sl.registerLazySingleton(() => DeleteRestaurant(sl()));

  // User usecase
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => GetGoogleRedirectUseCase(sl()));
  sl.registerLazySingleton(() => HandleGoogleCallbackUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));

  // User local datasource (secure token storage)
  sl.registerLazySingleton(() => FlutterSecureStorage());
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(secureStorage: sl()),
  );

  // User repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      network: sl(),
      localDataSource: sl(),
    ),
  );

  // User Datasource
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );

  // Restaurant Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: sl(), network: sl()),
  );

  // Restaurant Data sources
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
