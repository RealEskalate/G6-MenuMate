import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection.dart' as di;
import 'core/temp/app_config.dart';
import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/restaurant_management/presentation/pages/restaurant_debug_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConfigPresets.production();
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
      child: const MaterialApp(title: 'DinQ', home: RestaurantDebugPage()),
    );
  }
}
