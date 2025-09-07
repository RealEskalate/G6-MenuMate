import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
import '../../../restaurant_management/data/model/restaurant_model.dart';
import '../../../restaurant_management/data/datasources/restaurant_remote_data_source.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/nearby_restaurant_card.dart';
import '../widgets/popular_dish_card.dart';
import '../widgets/search_results_popup.dart';
import '../../domain/entities/menu.dart' as models;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<RestaurantModel> _searchResults = [];
  bool _isSearching = false;
  String _currentSearchQuery = '';
  Timer? _debounceTimer;
  bool _isLoadingRestaurants = true;
  List<Restaurant> _restaurants = [];
  String _errorMessage = '';

  late final margheritaPizza = models.Item(
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

  late final salmonSashimi = models.Item(
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

  late final cheeseburger = models.Item(
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

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  void _loadRestaurants() {
    final restaurantBloc = BlocProvider.of<RestaurantBloc>(context);
    restaurantBloc.add(const LoadRestaurants(page: 1, pageSize: 10));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    print('🔍 Search input changed: "$query"');

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear results if query is empty
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _currentSearchQuery = '';
      });
      return;
    }

    // Start new timer for debounced search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    print('🚀 Performing search for: "$query"');

    setState(() {
      _isSearching = true;
      _currentSearchQuery = query;
    });

    try {
      // TODO: Inject the datasource/repository properly
      // For now, we'll use a direct HTTP call
      print('🌐 Making API call to backend...');

      // This should be replaced with proper dependency injection
      // For debugging, we'll use a direct HTTP call
      final results = await _searchRestaurantsFromBackend(query);

      print('✅ Search completed. Found ${results.length} restaurants');

      setState(() {
        _searchResults = results;
      });

      if (results.isNotEmpty) {
        _showSearchResults();
      }

    } catch (e) {
      print('❌ Search failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<List<RestaurantModel>> _searchRestaurantsFromBackend(String query) async {
    print('🔧 _searchRestaurantsFromBackend called with query: "$query"');

    try {
      // Get the injected datasource
      final dataSource = GetIt.instance<RestaurantRemoteDataSource>();
      print('📡 Using injected RestaurantRemoteDataSource');

      // Call the search method
      final results = await dataSource.searchRestaurants(
        name: query,
        page: 1,
        pageSize: 10,
      );

      print('✅ Backend search completed. Found ${results.length} restaurants');
      return results;

    } catch (e) {
      print('💥 Error in _searchRestaurantsFromBackend: $e');
      throw e;
    }
  }

  void _showSearchResults() {
    showDialog(
      context: context,
      builder: (context) => SearchResultsPopup(
        restaurants: _searchResults,
        isLoading: false,
        searchQuery: _currentSearchQuery,
        onClose: () => Navigator.of(context).pop(),
        onRestaurantTap: (restaurant) {
          Navigator.of(context).pop(); // Close search popup
          Navigator.pushNamed(
            context,
            AppRoute.restaurant,
            arguments: {'restaurantId': restaurant.slug},
          );
        },
      ),
    );
  }

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: BlocListener<RestaurantBloc, RestaurantState>(
          listener: (context, state) {
            if (state is RestaurantsLoaded) {
              setState(() {
                _restaurants = state.restaurants;
                _isLoadingRestaurants = false;
                _errorMessage = '';
              });
            } else if (state is RestaurantError) {
              setState(() {
                _errorMessage = state.message;
                _isLoadingRestaurants = false;
              });
            } else if (state is RestaurantLoading) {
              setState(() {
                _isLoadingRestaurants = true;
              });
            }
          },
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
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search by restaurant or dish',
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nearby Restaurants
                  const Text(
                    'Nearby Restaurants',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 12),
                  
                  // Show loading indicator or error message
                  if (_isLoadingRestaurants)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error: $_errorMessage',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  // Show restaurants from API
                  else if (_restaurants.isNotEmpty)
                    ..._restaurants.map((restaurant) => NearbyRestaurantCard(
                          imageUrl: restaurant.logoImage ?? 
                              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
                          name: restaurant.restaurantName,
                          cuisine: restaurant.tags?.isNotEmpty == true ? restaurant.tags!.first : 'Restaurant',
                          distance: '${(restaurant.viewCount / 100).toStringAsFixed(1)} km away',
                          rating: restaurant.averageRating,
                          reviews: (restaurant.averageRating * 20).round(),
                          onViewMenu: () {
                            Navigator.pushNamed(
                              context,
                              AppRoute.restaurant,
                              arguments: {'restaurantId': restaurant.slug},
                            );
                          },
                        )).toList()
                  // Fallback to hardcoded restaurants if API returns empty list
                  else
                    ...[                  
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
      ),
      bottomNavigationBar: BottomNavbar(
        currentTab: BottomNavTab.explore,
        onTabSelected: (tab) => _onTabSelected(context, tab),
      ),
    );
  }
}

