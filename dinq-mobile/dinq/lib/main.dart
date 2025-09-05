import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/util/theme.dart';
import 'features/dinq/restaurant_management/data/model/restaurant_model.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_event.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_state.dart';
import 'features/dinq/user/domain/usecases/user/register_user_usecase.dart';
import 'features/dinq/user/presentation/bloc/user_bloc.dart';
import 'features/dinq/user/presentation/bloc/user_event.dart';
import 'features/dinq/user/presentation/bloc/user_state.dart';
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<RestaurantBloc>(create: (_) => di.sl<RestaurantBloc>()),
          BlocProvider<UserBloc>(create: (_) => di.sl<UserBloc>()),
        ],
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
    final firstController = TextEditingController(text: 'demo');
    final secondController = TextEditingController(text: 'demo');
    final idController = TextEditingController(text: '');
    final usernameController = TextEditingController(text: 'demo_user');
    final emailController = TextEditingController(text: 'demo@example.com');
    final passwordController = TextEditingController(text: 'password');
    final jsonController = TextEditingController(
      text: jsonEncode({
        'name': 'Demo Restaurant',
        'slug': 'demo-slug',
        'description': 'Created from demo page',
      }),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant API Demo (Bloc)')),
      body: SingleChildScrollView(
        child: Padding(
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
              SizedBox(
                height: 200,
                child: TextField(
                  controller: jsonController,
                  decoration: const InputDecoration(
                    labelText: 'JSON body (create/update)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
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
                          jsonDecode(jsonController.text)
                              as Map<String, dynamic>;
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
                        UpdateRestaurantEvent(
                          model,
                          slugController.text.trim(),
                        ),
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
              Builder(
                builder: (context) {
                  final isRegisterRegistered = di.sl
                      .isRegistered<RegisterUserUseCase>();
                  return Text(
                    'Register usecase registered: ${isRegisterRegistered ? 'yes' : 'no'}',
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text('User Register (demo):'),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'username'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'password'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: firstController,
                decoration: const InputDecoration(labelText: 'first name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: secondController,
                decoration: const InputDecoration(labelText: 'last name'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<UserBloc>().add(
                    RegisterUserEvent(
                      username: usernameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      authProvider: 'EMAIL',
                      firstName: firstController.text.trim(),
                      lastName: secondController.text.trim(),
                    ),
                  );
                },
                child: const Text('Register User'),
              ),
              const SizedBox(height: 8),
              BlocBuilder<UserBloc, dynamic>(
                builder: (context, state) {
                  if (state is UserLoading) return const Text('Registering...');
                  if (state is UserRegistered) return Text(state.user.id);
                  if (state is UserError)
                    return Text('Error: ${state.message}');
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),
              const Text('Response:'),
              const SizedBox(height: 6),
              SizedBox(
                height: 200,
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
      ),
    );
  }
}
