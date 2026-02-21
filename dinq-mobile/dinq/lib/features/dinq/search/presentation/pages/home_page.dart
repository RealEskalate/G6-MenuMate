import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/theme.dart';
import '../../../../../injection_container.dart';
import '../../../auth/presentation/bloc/registration/registration_bloc.dart';
import '../../../restaurant_management/data/datasources/restaurant_remote_data_source_impl.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
import '../bloc/HomeBloc/home_bloc.dart';
import '../bloc/HomeBloc/home_event.dart';
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
    _tabController = TabController(length: tabs.length, vsync: this);

    _tabController.animation?.addListener(() {
      setState(() {}); // updates tab highlight in real time
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _tabBackground(double tabIndex) {
    final current = _tabController.animation!.value;
    final diff = (tabIndex - current).abs();
    if (diff < 0.5) return const Color(0xFFF97316);
    return const Color(0xFFF3F4F6);
  }

  Color _tabTextColor(double tabIndex) {
    final current = _tabController.animation!.value;
    final diff = (tabIndex - current).abs();
    if (diff < 0.5) return Colors.white;
    return const Color(0xFF4B5563);
  }

  @override
  Widget build(BuildContext context) {
    
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
          SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: tabs.map((tab) {
                    final index = tabs.indexOf(tab);
                    return GestureDetector(
                      onTap: () {
                        _tabController.animateTo(index,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeInOut);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _tabBackground(index.toDouble()),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: _tabTextColor(index.toDouble()),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 🔥 Main scrollable content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const ClampingScrollPhysics(),
              children: List.generate(tabs.length, (index) {
                if (index == 0) {
                  return BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      final restaurants = state.restaurants;

                      if (state.status == HomeStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (restaurants.isEmpty) {
                        return const Center(child: Text('No results'));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: restaurants.length + 2,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Restaurants',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryColor,
                                  ),
                                  child: const Text('See all'),
                                ),
                              ],
                            );
                          } else if (i <= restaurants.length) {
                            final r = restaurants[i - 1];
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
                                      child: RestaurantPage(restaurant: r),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (i == restaurants.length + 1 && state.currentPage < state.totalPages ) {
                            return Center(
                              child: TextButton(
                                  onPressed: () {

                                    context
                                        .read<HomeBloc>()
                                        .add(const LoadMoreRestaurants(pageSize: 10));
                                  },

                                    style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryColor),

                                  child: const Text(('Load More Restaurants'))),
                            );
                          }else if(i==restaurants.length+1){

                          }else {
                            // Popular Dishes
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Popular dishes',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primaryColor,
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
                                    itemCount: 4,
                                    itemBuilder: (_, index) {
                                      // Dummy data for popular dishes
                                      return PopularDishCard(
                                        imageUrl:
                                            'https://via.placeholder.com/150',
                                        name: 'Dish ${index + 1}',
                                        restaurant: 'Restaurant ${index + 1}',
                                        price: '\$${10 + index}.99',
                                        rating: 4.0 + index * 0.1,
                                        onTap: () {
                                          // Optional: show dish details
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }
                        },
                      );
                    },
                  );
                }

                return const Center(
                  child: Text('No items — data will come later'),
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar:

          const OwnerNavBar(isRestaurantOwner: , currentIndex: 0),
    );
  }
}
