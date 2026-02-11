import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
import '../../../restaurant_management/data/model/restaurant_model.dart';
import '../../../restaurant_management/data/datasources/restaurant_remote_data_source.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/popular_dish_card.dart';
import '../../domain/entities/menu.dart' as models;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<RestaurantModel> _searchResults = [];
  bool _isSearching = false;
  String _currentSearchQuery = '';
  Timer? _debounceTimer;
  late TabController _tabController;

  // Sample popular dishes
  late final margheritaPizza = models.Item(
    id: '1',
    name: 'Margherita Pizza',
    slug: 'margherita-pizza',
    categoryId: 'pizza',
    description: 'Classic pizza with tomato, mozzarella, and basil.',
    images: ['https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=400&q=80'],
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
    images: ['https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80'],
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
    images: ['https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80'],
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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _currentSearchQuery = '';
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _currentSearchQuery = query;
    });

    try {
      final results = await _searchRestaurantsFromBackend(query);
      setState(() {
        _searchResults = results;
      });

      _tabController.animateTo(0);
    } catch (e) {
      print('Search failed: $e');
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
    final dataSource = GetIt.instance<RestaurantRemoteDataSource>();
    return await dataSource.searchRestaurants(name: query, page: 1, pageSize: 10);
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 42,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[700],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: "Search Results"),
          Tab(text: "All"),
          Tab(text: "Nearby"),
          Tab(text: "Favorites"),
          Tab(text: "Registered"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              Image.asset(
                'assets/images/brand.png',
                height: 38,
                errorBuilder: (_, __, ___) => const FlutterLogo(size: 38),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search by restaurant or dish',
                suffixIcon: _isSearching
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 8),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Restaurants List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _searchResults.isEmpty
                          ? const Center(child: Text("No results yet"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 8),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final r = _searchResults[index];
                                return RestaurantCard(
                                  imageUrl: r.logoImage ?? '',
                                  name: r.restaurantName,
                                  cuisine: r.tags?.join(', ') ?? '',
                                  distance: '',
                                  rating: r.averageRating ?? 0,
                                  reviews: r.viewCount.toInt(),
                                  onViewMenu: () {
                                    Navigator.pushNamed(context, AppRoute.restaurant,
                                        arguments: {'restaurantId': r.slug});
                                  },
                                );
                              },
                            ),
                      const Center(child: Text("All Restaurants Placeholder")),
                      const Center(child: Text("Nearby Restaurants Placeholder")),
                      const Center(child: Text("Favorites Placeholder")),
                      const Center(child: Text("Registered Restaurants Placeholder")),
                    ],
                  ),
                ),

                // Popular Dishes Section
                SizedBox(
                  height: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Popular Dishes',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: [
                            PopularDishCard(
                              rating: 4,
                              imageUrl: margheritaPizza.images![0],
                              name: margheritaPizza.name,
                              restaurant: 'Bella Italia',
                              price: '\$18.99',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoute.itemDetail,
                                    arguments: {'item': margheritaPizza});
                              },
                            ),
                            PopularDishCard(
                              rating: 4,
                              imageUrl: salmonSashimi.images![0],
                              name: salmonSashimi.name,
                              restaurant: 'Sakura Sushi',
                              price: '\$24.99',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoute.itemDetail,
                                    arguments: {'item': salmonSashimi});
                              },
                            ),
                            PopularDishCard(
                              rating: 4,
                              imageUrl: cheeseburger.images![0],
                              name: cheeseburger.name,
                              restaurant: 'Burger Haven',
                              price: '\$15.99',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoute.itemDetail,
                                    arguments: {'item': cheeseburger});
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const OwnerNavBar(isRestaurantOwner: true, currentIndex: 0),
    );
  }
}
