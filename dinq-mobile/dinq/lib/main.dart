import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart' as di;
import 'core/util/theme.dart';
import 'features/dinq/restaurant_management/data/model/restaurant_model.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_event.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MenuMate - API Demo',
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
      home: BlocProvider<RestaurantBloc>(
        create: (_) => di.sl<RestaurantBloc>(),
        child: const DemoRestaurantPage(),
      ),
    );
  }
}

class DemoRestaurantPage extends StatelessWidget {
  const DemoRestaurantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final slugController = TextEditingController(text: 'demo-slug');
    final idController = TextEditingController(text: '');
    final jsonController = TextEditingController(
      text: jsonEncode({
        'name': 'Demo Restaurant',
        'slug': 'demo-slug',
        'description': 'Created from demo page',
      }),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant API Demo (Bloc)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: slugController,
              decoration: const InputDecoration(
                labelText: 'Slug (for GET/PUT)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID (for DELETE)'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: jsonController,
                decoration: const InputDecoration(
                  labelText: 'JSON body (create/update)',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final body =
                        jsonDecode(jsonController.text) as Map<String, dynamic>;
                    final model = RestaurantModel.fromMap(body);
                    context.read<RestaurantBloc>().add(
                      CreateRestaurantEvent(model),
                    );
                  },
                  child: const Text('Create'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<RestaurantBloc>().add(
                    const LoadRestaurants(page: 1, pageSize: 20),
                  ),
                  child: const Text('List'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<RestaurantBloc>().add(
                    LoadRestaurantBySlug(slugController.text.trim()),
                  ),
                  child: const Text('Get by Slug'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final model = RestaurantModel.fromMap(
                      jsonDecode(jsonController.text) as Map<String, dynamic>,
                    );
                    context.read<RestaurantBloc>().add(
                      UpdateRestaurantEvent(model, slugController.text.trim()),
                    );
                  },
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<RestaurantBloc>().add(
                    DeleteRestaurantEvent(idController.text.trim()),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Response:'),
            const SizedBox(height: 6),
            Expanded(
              child: BlocBuilder<RestaurantBloc, RestaurantState>(
                builder: (context, state) {
                  if (state is RestaurantLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state is RestaurantError)
                    return Text('Error: ${state.message}');
                  if (state is RestaurantsLoaded)
                    return Text('Restaurants: ${state.restaurants.length}');
                  if (state is RestaurantLoaded)
                    return Text('Restaurant: ${state.restaurant.name}');
                  if (state is RestaurantActionSuccess)
                    return Text(state.message);
                  if (state is MenuLoaded)
                    return Text('Menu: ${state.menu.id}');
                  if (state is ReviewsLoaded)
                    return Text('Reviews: ${state.reviews.length}');
                  if (state is UserImagesLoaded)
                    return Text('Images: ${state.images.length}');
                  return const Text('Idle');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
