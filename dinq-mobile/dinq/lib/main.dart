import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection.dart' as di;
import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/restaurant_management/presentation/pages/restaurant_menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        title: 'DineQ - Restaurant Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DineQ'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to DineQ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Restaurant Management System',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to restaurant menu page
                // For demo purposes, using a hardcoded restaurant ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RestaurantMenuPage(
                      restaurantId:
                          'restaurant-1', // This should come from a restaurant list
                    ),
                  ),
                );
              },
              child: const Text('View Restaurant Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
