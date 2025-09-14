// main.dart - CORRECTED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/routing/app_route.dart';
// import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'core/util/theme.dart';
// ...existing code...
import 'features/auth/presentation/Pages/auth_gate.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/user_bloc.dart';
import 'features/restaurant_management/presentation/bloc/menu_bloc.dart';
import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/restaurant_management/presentation/bloc/review_bloc.dart';
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
    // Check for existing authentication on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.sl<AuthBloc>().add(CheckAuthEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RestaurantBloc>(
          // HomePage will request restaurants when it has a valid context.
          create: (context) => di.sl<RestaurantBloc>(),
        ),
        BlocProvider<MenuBloc>(
          create: (context) => di.sl<MenuBloc>(),
        ),
        BlocProvider<ReviewBloc>(
          create: (context) => di.sl<ReviewBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<UserBloc>(),
        ),
      ],
      child: MaterialApp(
        home: const AuthGate(),
        onGenerateRoute: AppRoute.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
      ),
    );
  }
}
