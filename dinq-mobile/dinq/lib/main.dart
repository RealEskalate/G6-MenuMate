// main.dart - CORRECTED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/routing/app_route.dart';
// import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'core/util/theme.dart';
// ...existing code...
import 'features/dinq/auth/presentation/Pages/onboarding_first.dart';
import 'features/dinq/auth/presentation/bloc/user_bloc.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RestaurantBloc>(
          // create bloc but don't dispatch LoadRestaurants here;
          // HomePage will request restaurants when it has a valid context.
          create: (context) => di.sl<RestaurantBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<UserBloc>(),
        ),
      ],
      child: MaterialApp(
        
        // start at an auth gate that decides whether to show login or main shell
        home: const OnboardingFirst(),
        onGenerateRoute: AppRoute.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
      ),
    );
  }
}
