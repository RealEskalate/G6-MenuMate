import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection.dart' as di;
import 'core/routing/app_routing.dart';
import 'core/temp/app_config.dart';
import 'core/utils/theme.dart';
import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConfigPresets.developmentDemo();
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
        title: 'DinQ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/explore',
        onGenerateRoute: generateRoute,
      ),
    );
  }
}


