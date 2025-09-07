import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/item.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
// ...existing code... (bottom_navbar not needed in HomePage as OwnerNavBar is used)
import '../widgets/nearby_restaurant_card.dart';
import '../widgets/popular_dish_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  bool _requestedPopularMenu = false;

  @override
  Widget build(BuildContext context) {
    // Small sample items using the domain Item entity (match required params)
    final margheritaPizza = const Item(
      id: '1',
      name: 'Margherita Pizza',
      nameAm: 'Margherita Pizza',
      slug: 'margherita-pizza',
      menuSlug: 'menu-1',
      description: 'Classic pizza with tomato, mozzarella, and basil.',
      images: [
        'https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=400&q=80',
      ],
      price: 18.99,
      currency: '\$',
      allergies: null,
      allergiesAm: null,
      tabTags: null,
      ingredients: null,
      ingredientsAm: null,
      preparationTime: null,
      nutritionalInfo: null,
      viewCount: 0,
      averageRating: 4.8,
      reviewIds: [],
    );

    final salmonSashimi = const Item(
      id: '2',
      name: 'Salmon Sashimi',
      nameAm: 'Salmon Sashimi',
      slug: 'salmon-sashimi',
      menuSlug: 'menu-1',
      description: 'Fresh salmon sashimi slices.',
      images: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      ],
      price: 24.99,
      currency: '\$',
      allergies: null,
      allergiesAm: null,
      tabTags: null,
      ingredients: null,
      ingredientsAm: null,
      preparationTime: null,
      nutritionalInfo: null,
      viewCount: 0,
      averageRating: 4.6,
      reviewIds: [],
    );

    final cheeseburger = const Item(
      id: '3',
      name: 'Cheeseburger',
      nameAm: 'Cheeseburger',
      slug: 'cheeseburger',
      menuSlug: 'menu-1',
      description: 'Juicy cheeseburger with lettuce and tomato.',
      images: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
      ],
      price: 15.99,
      currency: '\$',
      allergies: null,
      allergiesAm: null,
      tabTags: null,
      ingredients: null,
      ingredientsAm: null,
      preparationTime: null,
      nutritionalInfo: null,
      viewCount: 0,
      averageRating: 4.5,
      reviewIds: [],
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: BlocBuilder<RestaurantBloc, RestaurantState>(
          builder: (context, state) {
            if (state is RestaurantInitial) {
              // dispatch initial load now that builder has a valid context
              context
                  .read<RestaurantBloc>()
                  .add(const LoadRestaurants(page: 1, pageSize: 20));
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RestaurantLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RestaurantsLoaded) {
              final restaurants = state.restaurants;

              // request popular menu for first restaurant only once
              if (restaurants.isNotEmpty && !_requestedPopularMenu) {
                _requestedPopularMenu = true;
                context
                    .read<RestaurantBloc>()
                    .add(LoadMenu(restaurantSlug: restaurants.first.slug));
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  // Logo / header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/brand.png',
                        height: 38,
                        errorBuilder: (_, __, ___) =>
                            const FlutterLogo(size: 38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Search bar
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

                  // Nearby title
                  const Text('Nearby Restaurants',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 12),

                  // Nearby restaurants list
                  ...restaurants.map((r) {
                    return NearbyRestaurantCard(restaurant: r);
                  }),

                  const SizedBox(height: 28),

                  // Popular Dishes title
                  const Text('Popular Dishes',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 12),

                  // Horizontal popular list
                  SizedBox(
                    height: 220,
                    child: BlocBuilder<RestaurantBloc, RestaurantState>(
                      builder: (context, blocState) {
                        List<Item> popularItems = [];
                        if (blocState is MenuLoaded) {
                          popularItems = blocState.menu.items.take(10).toList();
                        }

                        if (popularItems.isNotEmpty) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: popularItems.length,
                            itemBuilder: (context, index) {
                              final item = popularItems[index];
                              return PopularDishCard(
                                item: item,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoute.itemDetail,
                                      arguments: {'item': item});
                                },
                              );
                            },
                          );
                        }

                        // fallback demo list
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            const SizedBox(width: 4),
                            PopularDishCard(
                              item: margheritaPizza,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoute.itemDetail,
                                    arguments: {'item': margheritaPizza});
                              },
                            ),
                            PopularDishCard(
                              item: salmonSashimi,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoute.itemDetail,
                                    arguments: {'item': salmonSashimi});
                              },
                            ),
                            PopularDishCard(
                              item: cheeseburger,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoute.itemDetail,
                                    arguments: {'item': cheeseburger});
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            // fallback for other states
            return const Center(child: const Text('No restaurants available'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          // TODO: Implement QR scan
          Navigator.pushNamed(context, AppRoute.qrcode);
        },
        child: const Icon(
          Icons.qr_code_scanner,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}
