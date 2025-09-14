import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/item.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../widgets/nearby_restaurant_card.dart';
import '../widgets/popular_dish_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _searchInFlight = false;
  List<Restaurant> _searchResults = [];

  // demo items
  late final Item margheritaPizza = const Item(
    id: '1',
    name: 'Margherita Pizza',
    nameAm: 'ማርገሪታ ፒዛ',
    slug: 'margherita-pizza',
    menuSlug: 'pizza-menu',
    description: 'Classic pizza with tomato, mozzarella, and basil.',
    images: [
      'https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=400&q=80',
    ],
    price: 18.99,
    currency: '\$',
    viewCount: 150,
    averageRating: 4.8,
    reviewIds: [],
  );

  late final Item salmonSashimi = const Item(
    id: '2',
    name: 'Salmon Sashimi',
    nameAm: 'ሳልሞን ሳሺሚ',
    slug: 'salmon-sashimi',
    menuSlug: 'sushi-menu',
    description: 'Fresh salmon sashimi slices.',
    images: [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
    ],
    price: 24.99,
    currency: '\$',
    viewCount: 120,
    averageRating: 4.6,
    reviewIds: [],
  );

  late final Item cheeseburger = const Item(
    id: '3',
    name: 'Cheeseburger',
    nameAm: 'ቺዝበርገር',
    slug: 'cheeseburger',
    menuSlug: 'burger-menu',
    description: 'Juicy cheeseburger with lettuce and tomato.',
    images: [
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
    ],
    price: 15.99,
    currency: '\$',
    viewCount: 200,
    averageRating: 4.5,
    reviewIds: [],
  );

  @override
  void initState() {
    super.initState();
    // Only load restaurants if not already loaded
    final currentState = context.read<RestaurantBloc>().state;
    if (currentState is! RestaurantsLoaded &&
        currentState is! RestaurantLoading) {
      context
          .read<RestaurantBloc>()
          .add(const LoadRestaurants(page: 1, pageSize: 20));
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchInFlight = true;
    });

    try {
      // simulate async search (replace with real repository call)
      await Future.delayed(const Duration(milliseconds: 800));
      final blocState = context.read<RestaurantBloc>().state;
      if (blocState is RestaurantsLoaded) {
        _searchResults = blocState.restaurants
            .where((r) =>
                r.restaurantName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _searchResults = [];
      }
    } catch (e) {
      // Handle search error
      _searchResults = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _searchInFlight = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final popularItems = [
      salmonSashimi,
      margheritaPizza,
      cheeseburger,
      salmonSashimi,
      margheritaPizza,
      cheeseburger,
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/brand.png',
                    height: 38,
                    errorBuilder: (_, __, ___) => const FlutterLogo(size: 38),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey),
                          hintText: 'Search by restaurant or dish',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Restaurants + Popular dishes
            Expanded(
              child: BlocBuilder<RestaurantBloc, RestaurantState>(
                builder: (context, state) {
                  if (state is RestaurantInitial ||
                      state is RestaurantLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RestaurantError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load restaurants',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<RestaurantBloc>().add(
                                  const LoadRestaurants(page: 1, pageSize: 20));
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is RestaurantsLoaded) {
                    final restaurantsToShow =
                        _isSearching ? _searchResults : state.restaurants;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurants section
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Nearby Restaurants',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: _searchInFlight
                              ? const Center(child: CircularProgressIndicator())
                              : restaurantsToShow.isEmpty
                                  ? Center(
                                      child: Text(_isSearching
                                          ? 'No results for "${_searchController.text}"'
                                          : 'No restaurants available'),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      itemCount: restaurantsToShow.length,
                                      itemBuilder: (context, index) {
                                        final r = restaurantsToShow[index];
                                        return NearbyRestaurantCard(
                                            restaurant: r);
                                      },
                                    ),
                        ),

                        // Popular Dishes section
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Popular Dishes',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 5),
                            itemCount: popularItems.length,
                            itemBuilder: (context, index) {
                              final item = popularItems[index];
                              return PopularDishCard(
                                item: item,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoute.itemDetail,
                                  arguments: {'item': item},
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<RestaurantBloc>()
                            .add(const LoadRestaurants(page: 1, pageSize: 20));
                      },
                      child: const Text('Retry'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => Navigator.pushNamed(context, AppRoute.qrcode),
        child: const Icon(Icons.qr_code_scanner, size: 32, color: Colors.white),
      ),
    );
  }
}
