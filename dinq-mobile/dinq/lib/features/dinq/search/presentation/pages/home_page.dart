import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
import '../../domain/entities/menu.dart' as models;
import '../widgets/bottom_navbar.dart';
import '../widgets/nearby_restaurant_card.dart';
import '../widgets/popular_dish_card.dart';
import 'package:dinq/features/dinq/search/domain/entities/menu.dart';
import 'package:dinq/features/dinq/search/presentation/pages/restaurant_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  // Add static method to create dummy restaurants for testing
  static List<Restaurant> createDummyRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'Pizza Palace',
        slug: 'pizza-palace',
        description: 'Best pizza in town with authentic Italian recipes.',
        address: '123 Main St, Anytown, USA',
        images: [
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
        ],
        rating: 4.7,
        reviewCount: 120,
        priceRange: '\$\$',
        cuisines: ['Italian', 'Pizza'],
        openingHours: '9:00 AM - 10:00 PM',
        latitude: 37.7749,
        longitude: -122.4194,
      ),
      Restaurant(
        id: '2',
        name: 'Sushi Delight',
        slug: 'sushi-delight',
        description: 'Fresh and delicious Japanese cuisine.',
        address: '456 Oak St, Anytown, USA',
        images: [
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
        ],
        rating: 4.9,
        reviewCount: 200,
        priceRange: '\$\$\$',
        cuisines: ['Japanese', 'Sushi'],
        openingHours: '11:00 AM - 11:00 PM',
        latitude: 37.7833,
        longitude: -122.4167,
      ),
      Restaurant(
        id: '3',
        name: 'Burger Joint',
        slug: 'burger-joint',
        description: 'Juicy burgers and crispy fries.',
        address: '789 Pine St, Anytown, USA',
        images: [
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
        ],
        rating: 4.5,
        reviewCount: 150,
        priceRange: '\$',
        cuisines: ['American', 'Burgers'],
        openingHours: '10:00 AM - 9:00 PM',
        latitude: 37.7850,
        longitude: -122.4200,
      ),
    ];
  }

  // Add static method to create dummy menu for testing
  static models.Menu createDummyMenu(String restaurantId) {
    return models.Menu(
      id: 'menu-$restaurantId',
      restaurantId: restaurantId,
      name: 'Main Menu',
      description: 'Our delicious offerings',
      tabs: [
        models.Tab(
          id: 'tab1',
          name: 'Popular',
          items: [
            models.Item(
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
            ),
            models.Item(
              id: '2',
              name: 'Salmon Sashimi',
              slug: 'salmon-sashimi',
              categoryId: 'sushi',
              description: 'Fresh salmon slices served with wasabi and soy sauce.',
              images: [
                'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
              ],
              price: 22.99,
              currency: '\$',
              isAvailable: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              averageRating: 4.9,
            ),
          ],
        ),
      ],
    );
  }
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _searchInFlight = false;
  List<Restaurant> _searchResults = [];

  // demo items
  late final models.Item margheritaPizza = models.Item(
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

  late final models.Item salmonSashimi = models.Item(
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

  late final models.Item cheeseburger = models.Item(
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
    // trigger initial load
    context
        .read<RestaurantBloc>()
        .add(const LoadRestaurants(page: 1, pageSize: 20));
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

    // simulate async search (replace with real repository call)
    await Future.delayed(const Duration(milliseconds: 800));
    final blocState = context.read<RestaurantBloc>().state;
    if (blocState is RestaurantsLoaded) {
      _searchResults = blocState.restaurants
          .where((r) =>
              r.restaurantName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      _searchInFlight = false;
    });
  }

  // Create dummy menu data for restaurant page
  Menu _createDummyMenu(String restaurantId) {
    return Menu(
      id: 'dummy-menu-id',
      restaurantId: restaurantId,
      branchId: 'dummy-branch-id',
      version: 1,
      isPublished: true,
      tabs: [
        Tab(
          id: 'tab1',
          menuId: 'dummy-menu-id',
          name: 'Main Menu',
          categories: [
            Category(
              id: 'cat1',
              tabId: 'tab1',
              name: 'Appetizers',
              items: [
                Item(
                  id: 'item1',
                  name: 'Samosas',
                  slug: 'samosas',
                  categoryId: 'cat1',
                  description: 'Crispy pastry filled with spiced potatoes and peas.',
                  price: 120.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1601050690597-df0568f70950'],
                  ingredients: ['Flour', 'Potatoes', 'Peas', 'Spices'],
                  preparationTime: 15,
                  calories: 250,
                ),
                Item(
                  id: 'item2',
                  name: 'Spring Rolls',
                  slug: 'spring-rolls',
                  categoryId: 'cat1',
                  description: 'Crispy rolls filled with vegetables and served with sweet chili sauce.',
                  price: 100.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1548811256-1627d99e7a57'],
                  ingredients: ['Rice paper', 'Carrots', 'Cabbage', 'Bean sprouts'],
                  preparationTime: 20,
                  calories: 180,
                ),
              ],
            ),
            Category(
              id: 'cat2',
              tabId: 'tab1',
              name: 'Main Courses',
              items: [
                Item(
                  id: 'item3',
                  name: 'Doro Wat',
                  slug: 'doro-wat',
                  categoryId: 'cat2',
                  description: 'Ethiopian spicy chicken stew served with injera.',
                  price: 250.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1567364667030-4d45a0a51201'],
                  ingredients: ['Chicken', 'Berbere', 'Onions', 'Garlic', 'Ginger'],
                  preparationTime: 45,
                  calories: 450,
                ),
                Item(
                  id: 'item4',
                  name: 'Tibs',
                  slug: 'tibs',
                  categoryId: 'cat2',
                  description: 'Ethiopian sautéed meat dish with vegetables.',
                  price: 220.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1567364667030-4d45a0a51201'],
                  ingredients: ['Beef', 'Peppers', 'Onions', 'Rosemary'],
                  preparationTime: 30,
                  calories: 380,
                ),
              ],
            ),
            Category(
              id: 'cat3',
              tabId: 'tab1',
              name: 'Desserts',
              items: [
                Item(
                  id: 'item5',
                  name: 'Baklava',
                  slug: 'baklava',
                  categoryId: 'cat3',
                  description: 'Sweet pastry made of layers of filo filled with chopped nuts and sweetened with honey.',
                  price: 150.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1519676867240-f03562e64548'],
                  ingredients: ['Phyllo dough', 'Nuts', 'Honey', 'Butter'],
                  preparationTime: 25,
                  calories: 300,
                ),
              ],
            ),
          ],
        ),
        Tab(
          id: 'tab2',
          menuId: 'dummy-menu-id',
          name: 'Drinks',
          categories: [
            Category(
              id: 'cat4',
              tabId: 'tab2',
              name: 'Hot Drinks',
              items: [
                Item(
                  id: 'item6',
                  name: 'Ethiopian Coffee',
                  slug: 'ethiopian-coffee',
                  categoryId: 'cat4',
                  description: 'Traditional Ethiopian coffee served in a jebena.',
                  price: 50.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1568031813264-d394c5d474b9'],
                  preparationTime: 15,
                  calories: 5,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final popularItems = [salmonSashimi, margheritaPizza, cheeseburger];

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
                          flex: 3,
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
                                          restaurant: r,
                                          onViewMenu: () {
                                            // Navigate to restaurant page with dummy menu
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => RestaurantPage(
                                                  restaurant: r,
                                                  menu: _createDummyMenu(r.id),
                                                ),
                                              ),
                                            );
                                          },
                                        );
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
                          child: ListView.builder(

                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
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

                  return const Center(
                      child: Text('Failed to load restaurants'));
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
      bottomNavigationBar: const OwnerNavBar(
        isRestaurantOwner: false,
        currentIndex: 0,
      ),
    );
  }

  // Add static method to create dummy restaurants for testing
  static List<Restaurant> createDummyRestaurants() {
    final now = DateTime.now();
    return [
      Restaurant(
        id: '1',
        slug: 'pizza-palace',
        restaurantName: 'Pizza Palace',
        managerId: 'manager1',
        restaurantPhone: '+1234567890',
        about: 'Best pizza in town with authentic Italian recipes.',
        logoImage: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
        coverImage: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
        previousSlugs: [],
        verificationStatus: 'verified',
        averageRating: 4.7,
        viewCount: 120,
        createdAt: now,
        updatedAt: now,
      ),
      Restaurant(
        id: '2',
        slug: 'sushi-delight',
        restaurantName: 'Sushi Delight',
        managerId: 'manager2',
        restaurantPhone: '+1234567891',
        about: 'Fresh and delicious Japanese cuisine.',
        logoImage: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
        coverImage: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
        previousSlugs: [],
        verificationStatus: 'verified',
        averageRating: 4.9,
        viewCount: 200,
        createdAt: now,
        updatedAt: now,
      ),
      Restaurant(
        id: '3',
        slug: 'burger-joint',
        restaurantName: 'Burger Joint',
        managerId: 'manager3',
        restaurantPhone: '+1234567892',
        about: 'Juicy burgers and crispy fries.',
        logoImage: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
        coverImage: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
        previousSlugs: [],
        verificationStatus: 'verified',
        averageRating: 4.5,
        viewCount: 150,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Add static method to create dummy menu for testing
  static models.Menu createDummyMenu(String restaurantId) {
    return models.Menu(
      id: 'menu-$restaurantId',
      restaurantId: restaurantId,
      name: 'Main Menu',
      description: 'Our delicious offerings',
      tabs: [
        models.Tab(
          id: 'tab1',
          name: 'Popular',
          items: [
            models.Item(
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
            ),
            models.Item(
              id: '2',
              name: 'Salmon Sashimi',
              slug: 'salmon-sashimi',
              categoryId: 'sushi',
              description: 'Fresh salmon slices served with wasabi and soy sauce.',
              images: [
                'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
              ],
              price: 22.99,
              currency: '\$',
              isAvailable: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              averageRating: 4.9,
            ),
          ],
        ),
      ],
    );
  }
}


// Create dummy restaurants for testing
List<Restaurant> createDummyRestaurants() {
  return [
    Restaurant(
      id: '1',
      restaurantName: 'Bella Italia',
      about: 'Authentic Italian cuisine in a cozy atmosphere.',
      verificationStatus: VerificationStatus.verified,
      contact: Contact(
        phone: '+1234567890',
        email: 'info@bellaitalia.com',
        social: {
          'instagram': '@bellaitalia',
          'facebook': 'BellaItalia',
        },
      ),
      averageRating: 4.7,
      bannerUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=500&q=60',
    ),
    Restaurant(
      id: '2',
      restaurantName: 'Sushi Master',
      about: 'Premium Japanese cuisine with fresh ingredients.',
      verificationStatus: VerificationStatus.verified,
      contact: Contact(
        phone: '+1987654321',
        email: 'info@sushimaster.com',
        social: {
          'instagram': '@sushimaster',
          'facebook': 'SushiMaster',
        },
      ),
      averageRating: 4.9,
      bannerUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=500&q=60',
    ),
    Restaurant(
      id: '3',
      restaurantName: 'Burger House',
      about: 'Gourmet burgers and craft beers.',
      verificationStatus: VerificationStatus.verified,
      contact: Contact(
        phone: '+1122334455',
        email: 'info@burgerhouse.com',
        social: {
          'instagram': '@burgerhouse',
          'facebook': 'BurgerHouse',
        },
      ),
      averageRating: 4.5,
      bannerUrl: 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=500&q=60',
    ),
  ];
}

