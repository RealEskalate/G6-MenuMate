import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/routing/app_route.dart';
import 'core/util/theme.dart';
import 'features/dinq/search/presentation/bloc/home_bloc.dart';
import 'features/dinq/search/presentation/bloc/home_event.dart';
import 'injection_container.dart' as di;

import 'features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';


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
    return MultiBlocProvider(
      providers: [
        /// Auth Bloc
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),

        /// Home Bloc
        BlocProvider<HomeBloc>(
          create: (_) => di.sl<HomeBloc>()
            ..add(
              const LoadRestaurants(
                page: 1,
                pageSize: 10,
              ),
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
