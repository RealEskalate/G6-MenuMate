// main.dart - CORRECTED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'core/util/theme.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_event.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_state.dart';
import 'features/dinq/restaurant_management/presentation/pages/digitize_menu_page.dart';
import 'injection_container.dart' as di;

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
        // temporary test screen for OCR upload
        home: const DigitizeMenuPage(),
        debugShowCheckedModeBanner: false,
        theme: appTheme,
      ),
    );
  }
}

class TestHome extends StatelessWidget {
  const TestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetMenu Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, state) {
                if (state is RestaurantLoading) {
                  return const CircularProgressIndicator();
                } else if (state is MenuLoaded) {
                  return Text('Menu id: ${state.menu.items[0].id}');
                } else if (state is RestaurantsLoaded) {
                  return Text(
                      'Menu id: ${state.restaurants[0].restaurantName}');
                } else if (state is RestaurantError) {
                  return Text('Error: ${state.message}');
                }
                return const Text('Waiting...');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context
                    .read<RestaurantBloc>()
                    .add(const LoadMenu('workers-5fbe131a'));
              },
              child: const Text('Load Menu'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context
                    .read<RestaurantBloc>()
                    .add(const LoadRestaurants(page: 1, pageSize: 20));
              },
              child: const Text('Load restaurant'),
            ),
          ],
        ),
      ),
    );
  }
}
