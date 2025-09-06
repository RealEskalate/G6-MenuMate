import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/item.dart' as models;
import '../../../restaurant_management/domain/entities/restaurant.dart'
    as restmodels;
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
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
    // Request restaurants when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<RestaurantBloc>()
          .add(const LoadRestaurants(page: 1, pageSize: 20));
    });
  }

  bool _requestedPopularMenu = false;

  @override
  Widget build(BuildContext context) {
    // Small sample items using the domain Item entity (match required params)
    final margheritaPizza = models.Item(
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
      reviewIds: const [],
    );

    final salmonSashimi = models.Item(
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
      reviewIds: const [],
    );

    final cheeseburger = models.Item(
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
      reviewIds: const [],
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, state) {
                if (state is RestaurantLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<restmodels.Restaurant> restaurants = [];
                if (state is RestaurantsLoaded) {
                  restaurants = state.restaurants;
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    // Logo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/brand.png', // Make sure this exists!
                          height: 38,
                          errorBuilder: (_, __, ___) =>
                              const FlutterLogo(size: 38),
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
                          horizontal: 14, vertical: 4),
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
                    const Text('Nearby Restaurants',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 12),

                    // Render restaurants from state or fallback to demo cards
                    if (restaurants.isNotEmpty)
                      ...restaurants.map((r) {
                        final name = r.restaurantName;
                        final slug = r.slug;
                        final imageUrl = r.coverImage ??
                            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80';

                        return NearbyRestaurantCard(
                          imageUrl: imageUrl,
                          name: name,
                          cuisine: 'Various',
                          distance: 'Nearby',
                          rating: r.averageRating,
                          reviews: 42,
                          onViewMenu: () {
                            Navigator.pushNamed(
                              context,
                              AppRoute.restaurant,
                              arguments: {'restaurantId': slug},
                            );
                          },
                        );
                      }).toList()
                    else ...[
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
                    ],
                    const SizedBox(height: 28),
                    // Popular Dishes (driven by menu loaded in RestaurantBloc)
                    const Text('Popular Dishes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Builder(builder: (context) {
                          // If restaurants are loaded, request menu for first restaurant once
                          if (state is RestaurantsLoaded &&
                              state.restaurants.isNotEmpty &&
                              !_requestedPopularMenu) {
                            _requestedPopularMenu = true;
                            context
                                .read<RestaurantBloc>()
                                .add(LoadMenu(state.restaurants.first.slug));
                          }

                          List<models.Item> popularItems = [];
                          if (state is MenuLoaded) {
                            popularItems = state.menu.items.take(10).toList();
                          }

                          if (popularItems.isNotEmpty) {
                            return Row(
                              children: popularItems.map((item) {
                                return PopularDishCard(
                                  rating: item.averageRating,
                                  imageUrl: item.images != null &&
                                          item.images!.isNotEmpty
                                      ? item.images![0]
                                      : '',
                                  name: item.name,
                                  restaurant: '',
                                  price:
                                      '${item.currency}${item.price.toStringAsFixed(2)}',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoute.itemDetail,
                                      arguments: {'item': item},
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          }

                          // fallback demo list
                          return Row(
                            children: [
                              const SizedBox(width: 4),
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
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                );
              },
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
