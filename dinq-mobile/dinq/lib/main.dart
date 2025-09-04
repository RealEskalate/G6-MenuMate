import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection.dart' as di;
import 'core/temp/app_config.dart';
import 'core/routing/app_route.dart';
import 'core/util/theme.dart';
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
        initialRoute: AppRoute.analytics,
        onGenerateRoute: AppRoute.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
      ),
    );
  }
}
