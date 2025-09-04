import 'package:flutter/material.dart';

<<<<<<< HEAD
import 'core/routing/app_routing.dart';
import 'core/util/theme.dart';
=======
import 'core/injection.dart' as di;
import 'core/temp/app_config.dart';
import 'core/routing/app_route.dart';
import 'core/util/theme.dart';
import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
>>>>>>> m-feature/restaurant-menu

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MenuMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
<<<<<<< HEAD
=======
      ],
      child: MaterialApp(
        initialRoute: AppRoute.analytics,
        onGenerateRoute: AppRoute.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
>>>>>>> m-feature/restaurant-menu
      ),
      initialRoute: '/qrcode',
      onGenerateRoute: generateRoute,
    );
  }
}
