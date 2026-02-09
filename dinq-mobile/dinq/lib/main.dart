// main.dart - CORRECTED
import 'package:dinq/features/dinq/auth/presentation/Pages/email_verfiction.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/verify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import 'core/injection.dart' as di;
// import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'core/routing/app_route.dart';
// import 'core/temp/app_config.dart';
import 'core/util/theme.dart';
import 'features/dinq/auth/presentation/Pages/onboarding_first.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ConfigPresets.developmentDemo();
  // Load environment variables before initializing DI so runtime
  // lookups (like ApiEndpoints.baseUrl) can access them.
  await dotenv.load(fileName: '.env');
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RestaurantBloc>(
          create: (context) => di.sl<RestaurantBloc>(),
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
