// main.dart - CORRECTED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routing/app_route.dart';
// import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'core/util/theme.dart';
// ...existing code...
import 'features/dinq/auth/presentation/Pages/login_page.dart';
import 'features/dinq/auth/presentation/bloc/user_bloc.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_event.dart';
import 'features/dinq/search/presentation/pages/home_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    context.read<RestaurantBloc>().add(const LoadRestaurants(page: 1, pageSize: 20));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RestaurantBloc>(
          create: (context) => di.sl<RestaurantBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<UserBloc>(),
        ),
      ],
      child: MaterialApp(
        // start at login and use centralized route generator
        home: const HomePage(),
        onGenerateRoute: AppRoute.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
      ),
    );
  }
}