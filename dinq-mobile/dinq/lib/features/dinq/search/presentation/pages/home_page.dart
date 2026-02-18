import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/theme.dart';
import '../../../../../injection_container.dart';
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

  final List<String> tabs = [
    'All',
    'Nearby',
    'Favorites',
    'Registered',
    'Top Rated',
    'Desserts'
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

  Color _tabBackground(bool isActive, bool isDark) {
    if (isActive) {
      return const Color(0xFFF97316); // orange-500
    }
    return isDark
        ? const Color(0xFF1F2937) // gray-800
        : const Color(0xFFF3F4F6); // gray-100
  }

  Color _tabTextColor(bool isActive, bool isDark) {
    if (isActive) return Colors.white;
    return isDark
        ? const Color(0xFF9CA3AF) // gray-400
        : const Color(0xFF4B5563); // gray-600
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
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

          // 🔥 Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                tabs: List.generate(tabs.length, (index) {
                  final isActive = _tabController.index == index;

                  return GestureDetector(
                    onTap: () => _tabController.animateTo(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _tabBackground(isActive, isDark),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: _tabTextColor(isActive, isDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Main Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(tabs.length, (index) {
                if (index == 0) {
                  return BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      final restaurants = state.restaurants;

                      if (state.status == HomeStatus.loading) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (restaurants.isEmpty) {
                        return const Center(child: Text('No results'));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔥 Header Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Restaurants',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to full restaurant list page
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        AppColors.primaryColor, // primary color
                                  ),
                                  child: const Text('See all'),
                                ),
                              ],
                            ),
                          ),

                          // Restaurant List
                          Expanded(
                            child: ListView.separated(
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
                                  cuisine: (r.tags != null &&
                                          r.tags!.isNotEmpty)
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
                                          child: RestaurantPage(
                                              restaurant: r),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                return const Center(
                  child: Text(
                    'No items — data will come later',
                  ),
                );
              }),
            ),
          ),

          // Popular Dishes
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular dishes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (_, i) {
                      return const SizedBox(); // replace with your PopularDishCard
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const OwnerNavBar(isRestaurantOwner: true, currentIndex: 0),
    );
  }
}
