import 'package:dinq/features/dinq/auth/presentation/Pages/email_verfiction.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/verify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/routing/app_route.dart';
import 'core/util/theme.dart';
import 'features/dinq/auth/data/datasources/auth_remote_data_source_impl.dart';
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
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'injection_container.dart' as di;
import 'features/dinq/auth/domain/repository/auth_repository.dart';
import 'core/network/api_client.dart';
import 'core/network/api_endpoints.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create API client
    final apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);

    // Create AuthRemoteDataSource
    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);

    // Create AuthRepositoryImpl
    final AuthRepository authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );

    // Create all use cases
    final userSignUp = UserSignUp(authRepository);
    final userSignIn = UserSignIn(authRepository);
    final userLogout = UserLogout(authRepository);
    final checkUsernameAvailability = CheckUsernameAvailability(authRepository);
    final checkEmailAvailability = CheckEmailAvailability(authRepository);
    final checkPhoneAvailability = CheckPhoneAvailability(authRepository);
    final forgotPassword = ForgotPassword(authRepository);
    final resetPassword = ResetPassword(authRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<RestaurantBloc>(
          create: (context) => di.sl<RestaurantBloc>(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            userSignUp: userSignUp,
            userSignIn: userSignIn,
            userLogout: userLogout,
            checkUsernameAvailability: checkUsernameAvailability,
            checkEmailAvailability: checkEmailAvailability,
            checkPhoneAvailability: checkPhoneAvailability,
            forgotPassword: forgotPassword,
            resetPassword: resetPassword,
          ),
        ),
      ],
      child: MaterialApp(
        initialRoute: AppRoute.onboarding,
        onGenerateRoute: AppRoute.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
      ),
    );
  }
}

