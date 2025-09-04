// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/restaurant_bloc.dart';
import '../bloc/restaurant_event.dart';
import '../bloc/restaurant_state.dart';
import '../../data/model/restaurant_model.dart';

class RestaurantDebugPage extends StatelessWidget {
  const RestaurantDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<RestaurantBloc>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () =>
                  bloc.add(const LoadRestaurants(page: 1, pageSize: 20)),
              child: const Text('Load Restaurants (page 1)'),
            ),
            ElevatedButton(
              onPressed: () =>
                  bloc.add(const LoadRestaurantBySlug('pizza-hut')),
              child: const Text('Load Restaurant by Slug (pizza-hut)'),
            ),
            ElevatedButton(
              onPressed: () {
                final restaurant = RestaurantModel(
                  id: 'debug-id',
                  name: 'Debug Resto',
                  description: 'desc',
                  address: 'addr',
                  phone: '000',
                  email: 'a@b.com',
                  image: '',
                  isActive: true,
                );
                bloc.add(CreateRestaurantEvent(restaurant));
              },
              child: const Text('Create Restaurant (debug)'),
            ),
            ElevatedButton(
              onPressed: () {
                final restaurant = RestaurantModel(
                  id: 'debug-id',
                  name: 'Debug Resto Updated',
                  description: 'desc',
                  address: 'addr',
                  phone: '111',
                  email: 'a@b.com',
                  image: '',
                  isActive: true,
                );
                bloc.add(UpdateRestaurantEvent(restaurant, 'debug-slug'));
              },
              child: const Text('Update Restaurant (debug)'),
            ),
            ElevatedButton(
              onPressed: () =>
                  bloc.add(const DeleteRestaurantEvent('debug-id')),
              child: const Text('Delete Restaurant (debug)'),
            ),
            const SizedBox(height: 16),
            const Text('Bloc state:'),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<RestaurantBloc, RestaurantState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(state.toString()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
