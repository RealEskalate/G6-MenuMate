import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
import '../widgets/nearby_restaurant_card.dart';
import '../widgets/popular_dish_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                // Logo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/brand.png', // Make sure this exists!
                      height: 38,
                      errorBuilder: (_, __, ___) => const FlutterLogo(size: 38),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search by restaurant or dish',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nearby Restaurants (BlocBuilder)
                const Text(
                  'Nearby Restaurants',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 12),
                BlocBuilder<RestaurantBloc, RestaurantState>(
                  builder: (context, state) {
                    if (state is RestaurantInitial) {
                      context.read<RestaurantBloc>().add(
                            const LoadRestaurants(page: 1, pageSize: 10),
                          );
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RestaurantLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RestaurantsLoaded) {
                      if (state.restaurants.isEmpty) {
                        return const Text('No restaurants found.');
                      }
                      return Column(
                        children: [
                          for (final restaurant in state.restaurants)
                            NearbyRestaurantCard(restaurant: restaurant),
                          const SizedBox(height: 28),
                        ],
                      );
                    } else if (state is RestaurantError) {
                      return Text(state.message,
                          style: const TextStyle(color: Colors.red));
                    }
                    return const SizedBox.shrink();
                  },
                ),

                SizedBox(
                  height: 220,
                  child: BlocBuilder<RestaurantBloc, RestaurantState>(
                    builder: (context, state) {
                      if (state is RestaurantLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is RestaurantsLoaded) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              ...(() {
                                final restaurants = state.restaurants;
                                if (restaurants.isEmpty) {
                                  return [const SizedBox(width: 8)];
                                }

                                final first = restaurants.first;
                                final List<Widget> widgets = [];

                                // Only try to get menu items if the property exists
                                List<dynamic> menuItems = [];
                                try {
                                  if ((first as dynamic).menus != null &&
                                      (first as dynamic).menus is List) {
                                    for (final m in (first as dynamic).menus) {
                                      if (m != null &&
                                          (m as dynamic).items != null &&
                                          (m as dynamic).items is List) {
                                        menuItems.addAll((m as dynamic).items);
                                      }
                                    }
                                  } else if ((first as dynamic).menu != null &&
                                      (first as dynamic).menu is List) {
                                    for (final m in (first as dynamic).menu) {
                                      if (m != null &&
                                          (m as dynamic).items != null &&
                                          (m as dynamic).items is List) {
                                        menuItems.addAll((m as dynamic).items);
                                      }
                                    }
                                  }
                                } catch (e) {
                                  // If property doesn't exist, do nothing
                                }

                                if (menuItems.isEmpty) {
                                  widgets.add(const SizedBox(width: 8));
                                  widgets.add(const Center(
                                      child: Text('No popular dishes yet.')));
                                  return widgets;
                                }

                                widgets.addAll(menuItems.map(
                                    (item) => PopularDishCard(item: item)));
                                return widgets;
                              })(),
                            ],
                          ),
                        );
                      } else if (state is RestaurantError) {
                        return Center(
                            child: Text(state.message,
                                style: const TextStyle(color: Colors.red)));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),

            // Floating QR Button
            Positioned(
              bottom: 50,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: AppColors.primaryColor,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoute.qrcode);
                },
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: OwnerNavBar(
        isRestaurantOwner: true,
        currentIndex: 0,
      ),
    );
  }
}
