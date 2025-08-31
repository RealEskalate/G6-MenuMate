import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/theme.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/restaurant.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/restaurant_event.dart';
import '../bloc/restaurant_state.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/nearby_restaurant_card.dart';
import '../widgets/popular_dish_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _onTabSelected(BuildContext context, BottomNavTab tab) {
    if (tab == BottomNavTab.explore) {
      // Already on home/explore, do nothing
    } else if (tab == BottomNavTab.favorites) {
      Navigator.pushReplacementNamed(context, '/favorites');
    } else if (tab == BottomNavTab.profile) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  void initState() {
    super.initState();
    // Load restaurants when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantBloc>().add(const LoadRestaurants());
    });
  }

  @override
  Widget build(BuildContext context) {
    final margheritaPizza = const Item(
      id: '1',
      name: 'Margherita Pizza',
      nameAm: 'Margherita Pizza',
      slug: 'margherita-pizza',
      categoryId: 'pizza',
      description: 'Classic pizza with tomato, mozzarella, and basil.',
      image: [
        'https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=400&q=80',
      ],
      price: 19,
      currency: '\$',
      viewCount: 0,
      averageRating: 4.8,
      reviewIds: [],
    );

    final salmonSashimi = const Item(
      id: '2',
      name: 'Salmon Sashimi',
      nameAm: 'Salmon Sashimi',
      slug: 'salmon-sashimi',
      categoryId: 'sushi',
      description: 'Fresh salmon sashimi slices.',
      image: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      ],
      price: 25,
      currency: '\$',
      viewCount: 0,
      averageRating: 4.6,
      reviewIds: [],
    );

    final cheeseburger = const Item(
      id: '3',
      name: 'Cheeseburger',
      nameAm: 'Cheeseburger',
      slug: 'cheeseburger',
      categoryId: 'burger',
      description: 'Juicy cheeseburger with lettuce and tomato.',
      image: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
      ],
      price: 16,
      currency: '\$',
      viewCount: 0,
      averageRating: 4.5,
      reviewIds: [],
    );
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                100,
              ), // extra bottom padding
              children: [
                // Logo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1527261834078-9b37d8b04f6f?auto=format&fit=crop&w=200&q=80',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
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
                // Nearby Restaurants
                const Text(
                  'Nearby Restaurants',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 12),
                BlocBuilder<RestaurantBloc, RestaurantState>(
                  builder: (context, state) {
                    if (state is RestaurantLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is RestaurantsLoaded) {
                      return Column(
                        children: state.restaurants.map((r) {
                          return NearbyRestaurantCard(
                            restaurant: r,
                            distance: '—',
                            rating: 0,
                            reviews: 0,
                            onViewMenu: () {
                              Navigator.pushNamed(
                                context,
                                '/restaurant',
                                arguments: {'restaurantId': r.id},
                              );
                            },
                          );
                        }).toList(),
                      );
                    }

                    // default static fallback (passes a Restaurant model)
                    return NearbyRestaurantCard(
                      restaurant: const Restaurant(
                        id: 'bella-italia',
                        name: 'Bella Italia',
                        description: 'Italian',
                        address: 'Unknown',
                        phone: '',
                        email: '',
                        image:
                            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
                        isActive: true,
                      ),
                      distance: '0.5 km away',
                      rating: 4.8,
                      reviews: 120,
                      onViewMenu: () {
                        Navigator.pushNamed(
                          context,
                          '/restaurant',
                          arguments: {'restaurantId': 'bella-italia'},
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),
                // Popular Dishes
                const Text(
                  'Popular Dishes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 170,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        PopularDishCard(
                          item: margheritaPizza,
                          restaurantName: 'Bella Italia',
                          priceLabel: '\$18.99',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/item-detail',
                              arguments: {'item': margheritaPizza},
                            );
                          },
                        ),
                        PopularDishCard(
                          item: salmonSashimi,
                          restaurantName: 'Sakura Sushi',
                          priceLabel: '\$24.99',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/item-detail',
                              arguments: {'item': salmonSashimi},
                            );
                          },
                        ),
                        PopularDishCard(
                          item: cheeseburger,
                          restaurantName: 'Burger Haven',
                          priceLabel: '\$15.99',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/item-detail',
                              arguments: {'item': cheeseburger},
                            );
                          },
                        ),
                      ],
                    ),
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
                  // TODO: Implement QR scan
                  Navigator.pushNamed(context, '/scanned-menu');
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
      bottomNavigationBar: BottomNavBar(
        selectedTab: BottomNavTab.explore,
        onTabSelected: (tab) => _onTabSelected(context, tab),
      ),
    );
  }
}
