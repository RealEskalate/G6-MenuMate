import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/constants/constants.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'features/dinq/auth/data/datasources/auth_remote_data_source.dart';
import 'features/dinq/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'features/dinq/auth/domain/repository/auth_repository.dart';
import 'features/dinq/auth/data/repository/auth_repository_impl.dart';
import 'features/dinq/auth/domain/usecases/check_email_availability.dart';
import 'features/dinq/auth/domain/usecases/check_phoneAvailability.dart';
import 'features/dinq/auth/domain/usecases/check_user_name_availability.dart';
import 'features/dinq/auth/domain/usecases/forgot_password.dart';
import 'features/dinq/auth/domain/usecases/reset_password.dart';
import 'features/dinq/auth/domain/usecases/user_log_out.dart';
import 'features/dinq/auth/domain/usecases/user_sign_in.dart';
import 'features/dinq/auth/domain/usecases/user_sign_up.dart';
import 'features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';

// Restaurant imports
import 'features/dinq/restaurant_management/data/datasources/restaurant_remote_data_source.dart';
import 'features/dinq/restaurant_management/data/datasources/restaurant_remote_data_source_impl.dart';
import 'features/dinq/restaurant_management/data/repositories/restaurant_repository_impl.dart';
import 'features/dinq/restaurant_management/domain/repositories/restaurant_repository.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/get_restaurants.dart';
import 'features/dinq/restaurant_management/domain/usecases/restaurant/search_restaurants.dart';
import 'features/dinq/search/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // -----------------------
  // Core
  // -----------------------
  sl.registerLazySingleton(() => Dio(BaseOptions(baseUrl: baseUrl)));
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ApiClient
  sl.registerLazySingleton(() => ApiClient(baseUrl: baseUrl));

  // -----------------------
  // Auth
  // -----------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton(() => UserSignUp(sl()));
  sl.registerLazySingleton(() => UserSignIn(sl()));
  sl.registerLazySingleton(() => UserLogout(sl()));
  sl.registerLazySingleton(() => CheckUsernameAvailability(sl()));
  sl.registerLazySingleton(() => CheckEmailAvailability(sl()));
  sl.registerLazySingleton(() => CheckPhoneAvailability(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));

  sl.registerFactory(() => AuthBloc(
        userSignUp: sl(),
        userSignIn: sl(),
        userLogout: sl(),
        checkUsernameAvailability: sl(),
        checkEmailAvailability: sl(),
        checkPhoneAvailability: sl(),
        forgotPassword: sl(),
        resetPassword: sl(),
      ));

  // -----------------------
  // Restaurant
  // -----------------------
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
      () => RestaurantRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<RestaurantRepository>(
      () => RestaurantRepositoryImpl(remoteDataSource: sl(), network: sl()));

  sl.registerLazySingleton(() => GetRestaurants(sl()));
  sl.registerLazySingleton(() => SearchRestaurants(sl()));

  sl.registerFactory(() => HomeBloc(
        getRestaurants: sl(),
        searchRestaurants: sl(),
      ));
}
