import '../../domain/entities/Restaurant.dart' as models;
import 'package:flutter/material.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/presentation/widgets/owner_navbar.dart';
import '../../domain/entities/menu.dart' as models;
import 'restaurant_page.dart';
import 'item_details_page.dart';
import '../widgets/bottom_navbar.dart';

class _FavoritesStore {
  static final Set<String> restaurantIds = <String>{};
  static final Set<String> dishIds = <String>{};
}

class FavouritesPage extends StatefulWidget {
  final List<models.Restaurant> allRestaurants;
  final List<models.Item> allDishes;

  const FavouritesPage({
    super.key,
    required this.allRestaurants,
    required this.allDishes,
  });

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
      Navigator.pushReplacementNamed(context, AppRoute.explore);
    } else if (tab == BottomNavTab.favorites) {
      // Already on favorites, do nothing
    } else if (tab == BottomNavTab.profile) {
      Navigator.pushReplacementNamed(context, AppRoute.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteRestaurantIds = _FavoritesStore.restaurantIds;
    final favoriteDishIds = _FavoritesStore.dishIds;

    final favoriteRestaurants = widget.allRestaurants
        .where((r) => favoriteRestaurantIds.contains(r.id))
        .toList();
    final favoriteDishes =
        widget.allDishes.where((d) => favoriteDishIds.contains(d.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved Items'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                          models.Item? dish;
                          try {
                            dish = widget.allDishes.firstWhere(
                              (d) => d.id == restaurant.id,
                            );
                          } catch (e) {
                            dish = widget.allDishes.isNotEmpty
                                ? widget.allDishes.first
                                : null;
                          }
                          return _buildRestaurantCard(
                            restaurant,
                            bannerUrl: dish?.images?.isNotEmpty == true
                                ? dish!.images!.first
                                : null,
                            rating: dish?.averageRating,
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
      bottomNavigationBar: const OwnerNavBar(
        currentIndex: 1,
        isRestaurantOwner: true,
      ),
      // bottomNavigationBar: BottomNavBar(
      //   selectedTab: BottomNavTab.favorites,
      //   onTabSelected: _onTabSelected,
      // ),
    );
  }

  Widget _buildRestaurantCard(
    models.Restaurant restaurant, {
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
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>

            //   ),
            // );
          },
          child: const Text('View Menu'),
        ),
      ),
    );
  }

  Widget _buildDishCard(models.Item dish) {
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
          child: dish.images != null && dish.images!.isNotEmpty
              ? Image.network(
                  dish.images!.first,
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
            if (dish.averageRating != null)
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
