import 'package:flutter/material.dart';

import '../../../../core/utils/theme.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/restaurant.dart';
import '../widgets/bottom_navbar.dart';
import 'item_details_page.dart';
import 'restaurant_page.dart';

class _FavoritesStore {
  static final Set<String> restaurantIds = <String>{};
  static final Set<String> dishIds = <String>{};
}

class FavouritesPage extends StatefulWidget {
  final List<Restaurant> allRestaurants;
  final List<Item> allDishes;

  const FavouritesPage({
    Key? key,
    required this.allRestaurants,
    required this.allDishes,
  }) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabSelected(BottomNavTab tab) {
    if (tab == BottomNavTab.explore) {
      Navigator.pushReplacementNamed(context, '/explore');
    } else if (tab == BottomNavTab.favorites) {
      // Already on favorites, do nothing
    } else if (tab == BottomNavTab.profile) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteRestaurantIds = _FavoritesStore.restaurantIds;
    final favoriteDishIds = _FavoritesStore.dishIds;

    final favoriteRestaurants = widget.allRestaurants
        .where((r) => favoriteRestaurantIds.contains(r.id))
        .toList();
    final favoriteDishes = widget.allDishes
        .where((d) => favoriteDishIds.contains(d.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved Items'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryColor,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: Colors.black54,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Restaurants'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${favoriteRestaurants.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Dishes'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${favoriteDishes.length}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Restaurants Tab
                favoriteRestaurants.isEmpty
                    ? const Center(child: Text('No favorite restaurants yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: favoriteRestaurants.length,
                        itemBuilder: (context, idx) {
                          final restaurant = favoriteRestaurants[idx];
                          // Use restaurant.image as banner (domain Restaurant has an image field)
                          return _buildRestaurantCard(
                            restaurant,
                            bannerUrl: restaurant.image.isNotEmpty
                                ? restaurant.image
                                : null,
                            rating: null,
                          );
                        },
                      ),
                // Dishes Tab
                favoriteDishes.isEmpty
                    ? const Center(child: Text('No favorite dishes yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: favoriteDishes.length,
                        itemBuilder: (context, idx) {
                          final dish = favoriteDishes[idx];
                          return _buildDishCard(dish);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedTab: BottomNavTab.favorites,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildRestaurantCard(
    Restaurant restaurant, {
    String? bannerUrl,
    double? rating,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: bannerUrl != null
              ? Image.network(
                  bannerUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
        ),
        title: Text(
          restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: rating != null
            ? Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : null,
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RestaurantPage(restaurantId: restaurant.id),
              ),
            );
          },
          child: const Text('View Menu'),
        ),
      ),
    );
  }

  Widget _buildDishCard(Item dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: dish.image != null && dish.image!.isNotEmpty
              ? Image.network(
                  dish.image!.first,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant_menu, color: Colors.grey),
                ),
        ),
        title: Text(
          dish.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dish.description != null)
              Text(
                dish.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 2),
                Text(
                  '${dish.averageRating}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsPage(item: dish),
              ),
            );
          },
          child: const Text('View Dish'),
        ),
      ),
    );
  }
}
