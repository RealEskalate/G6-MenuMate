import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/theme.dart';
import '../../../../../injection_container.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/pages/restaurant_details_page.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
import '../bloc/HomeBloc/home_bloc.dart';
import '../bloc/HomeBloc/home_state.dart';
import '../bloc/Menu_bloc/menu_bloc.dart';
import '../widgets/popular_dish_card.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> tabs = ['All', 'Nearby', 'Favorites', 'Registered'];

  final List<Map<String, dynamic>> popularDishes = [
    {
      'imageUrl': 'https://via.placeholder.com/140x100',
      'name': 'Spicy Ramen',
      'restaurant': 'Noodle House',
      'price': '\$9.99',
      'rating': 4.5,
    },
    {
      'imageUrl': 'https://via.placeholder.com/140x100',
      'name': 'Margherita Pizza',
      'restaurant': 'Pizzeria Uno',
      'price': '\$12.50',
      'rating': 4.7,
    },
    {
      'imageUrl': 'https://via.placeholder.com/140x100',
      'name': 'Chicken Biryani',
      'restaurant': 'Spice Villa',
      'price': '\$10.00',
      'rating': 4.6,
    },
    {
      'imageUrl': 'https://via.placeholder.com/140x100',
      'name': 'Sushi Platter',
      'restaurant': 'Sakura',
      'price': '\$18.00',
      'rating': 4.8,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        centerTitle: false,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/images/brand.png',
            height: 38,
            errorBuilder: (_, __, ___) => const FlutterLogo(size: 38),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, _) {
                  final animValue = _tabController.animation!.value;
                  return TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    indicatorPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[800],
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                    tabs: tabs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tab = entry.value;
                      final factor = (animValue - index).abs().clamp(0.0, 1.0);
                      final bgColor = Color.lerp(
                          Colors.transparent, Colors.grey[300], factor);
                      final textColor =
                          Color.lerp(Colors.white, Colors.grey[800], factor);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Expanded main content
          Expanded(
            child: Column(
              children: [
                // Restaurants Tab
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(tabs.length, (index) {
                      if (index == 0) {
                        return BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            final status = state.status;
                            final restaurants = state.restaurants;
                            final errorMessage = state.errorMessage;

                            if (status == null || status == HomeStatus.loading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (status == HomeStatus.error) {
                              return Center(
                                  child: Text(errorMessage ?? 'Error'));
                            } else if (status == HomeStatus.empty ||
                                restaurants.isEmpty) {
                              return Center(
                                child: Text(
                                  'No results',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: restaurants.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final r = restaurants[i];
                                return RestaurantCard(
                                  imageUrl: (r.logoImage ?? r.coverImage) ?? '',
                                  name: r.restaurantName,
                                  cuisine: (r.tags != null && r.tags!.isNotEmpty)
                                      ? r.tags!.first
                                      : '',
                                  distance: '',
                                  rating: (r.averageRating).toDouble(),
                                  reviews: 0,
                                  onViewMenu: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider<MenuBloc>(
                                          create: (_) => sl<MenuBloc>(),
                                          child:
                                              RestaurantPage(restaurant: r),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            'No items — data will come from backend filters later',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                    }),
                  ),
                ),

                // Popular Dishes Section (separated visually)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular dishes',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 170,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: popularDishes.length,
                          itemBuilder: (_, i) {
                            final d = popularDishes[i];
                            return PopularDishCard(
                              imageUrl: d['imageUrl'] as String,
                              name: d['name'] as String,
                              restaurant: d['restaurant'] as String,
                              price: d['price'] as String,
                              rating: d['rating'] as double,
                              onTap: () {},
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const OwnerNavBar(isRestaurantOwner: true, currentIndex: 0),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.qr_code_scanner, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
