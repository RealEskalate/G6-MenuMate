import 'package:flutter/material.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/nearby_restaurant_card.dart';
import '../widgets/popular_dish_card.dart';
import '../../domain/entities/menu.dart' as models;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _onTabSelected(BuildContext context, BottomNavTab tab) {
    if (tab == BottomNavTab.explore) {
      // Already on home/explore, do nothing
    } else if (tab == BottomNavTab.favorites) {
      Navigator.pushReplacementNamed(context, AppRoute.favorites);
    } else if (tab == BottomNavTab.profile) {
      Navigator.pushReplacementNamed(context, AppRoute.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final margheritaPizza = models.Item(
      id: '1',
      name: 'Margherita Pizza',
      slug: 'margherita-pizza',
      categoryId: 'pizza',
      description: 'Classic pizza with tomato, mozzarella, and basil.',
      images: [
        'https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=400&q=80',
      ],
      price: 18.99,
      currency: '\$',
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      averageRating: 4.8,
    );

    final salmonSashimi = models.Item(
      id: '2',
      name: 'Salmon Sashimi',
      slug: 'salmon-sashimi',
      categoryId: 'sushi',
      description: 'Fresh salmon sashimi slices.',
      images: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      ],
      price: 24.99,
      currency: '\$',
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      averageRating: 4.6,
    );

    final cheeseburger = models.Item(
      id: '3',
      name: 'Cheeseburger',
      slug: 'cheeseburger',
      categoryId: 'burger',
      description: 'Juicy cheeseburger with lettuce and tomato.',
      images: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
      ],
      price: 15.99,
      currency: '\$',
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      averageRating: 4.5,
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
                NearbyRestaurantCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
                  name: 'Bella Italia',
                  cuisine: 'Italian',
                  distance: '0.5 km away',
                  rating: 4.8,
                  reviews: 120,
                  onViewMenu: () {
                    Navigator.pushNamed(
                      context,
                      AppRoute.restaurant,
                      arguments: {'restaurantId': 'bella-italia'},
                    );
                  },
                ),
                NearbyRestaurantCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
                  name: 'Sakura Sushi',
                  cuisine: 'Japanese',
                  distance: '0.8 km away',
                  rating: 4.6,
                  reviews: 89,
                  onViewMenu: () {
                    Navigator.pushNamed(
                      context,
                      AppRoute.restaurant,
                      arguments: {'restaurantId': 'sakura-sushi'},
                    );
                  },
                ),
                NearbyRestaurantCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
                  name: 'Burger Haven',
                  cuisine: 'American',
                  distance: '1.2 km away',
                  rating: 4.5,
                  reviews: 156,
                  onViewMenu: () {
                    Navigator.pushNamed(
                      context,
                      AppRoute.restaurant,
                      arguments: {'restaurantId': 'burger-haven'},
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
                  height: 220,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 4),
                        PopularDishCard(
                          rating: 4,
                          imageUrl: margheritaPizza.images![0],
                          name: margheritaPizza.name,
                          restaurant: 'Bella Italia',
                          price: '\$18.99',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoute.itemDetail,
                              arguments: {'item': margheritaPizza},
                            );
                          },
                        ),
                        PopularDishCard(
                          rating: 4,
                          imageUrl: salmonSashimi.images![0],
                          name: salmonSashimi.name,
                          restaurant: 'Sakura Sushi',
                          price: '\$24.99',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoute.itemDetail,
                              arguments: {'item': salmonSashimi},
                            );
                          },
                        ),
                        PopularDishCard(
                          rating: 4,  
                          imageUrl: cheeseburger.images![0],
                          name: cheeseburger.name,
                          restaurant: 'Burger Haven',
                          price: '\$15.99',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoute.itemDetail,
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
      bottomNavigationBar: const OwnerNavBar(
        isRestaurantOwner: true,
        currentIndex: 0,
      ),
    );
  }
}
