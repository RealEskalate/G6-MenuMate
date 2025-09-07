import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../restaurant_management/domain/entities/menu.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart'
    as restmodels;
import '../../../restaurant_management/domain/entities/item.dart' as itemmodels;
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../widgets/bottom_navbar.dart';
import 'item_details_page.dart';

class _LocalFavoritesStore {
  final Set<String> restaurantIds = <String>{};
}

class RestaurantPage extends StatefulWidget {
  final restmodels.Restaurant restaurant;

  const RestaurantPage({super.key, required this.restaurant});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  Menu? _menu;
  bool _isFavorite = false;

  // Local lightweight favorites store to avoid importing private helpers
  static final _LocalFavoritesStore _localFavorites = _LocalFavoritesStore();

  void _onTabSelected(BottomNavTab tab) {
    if (tab == BottomNavTab.explore) {
      Navigator.pushReplacementNamed(context, AppRoute.explore);
    } else if (tab == BottomNavTab.favorites) {
      Navigator.pushReplacementNamed(context, AppRoute.favorites);
    } else if (tab == BottomNavTab.profile) {
      Navigator.pushReplacementNamed(context, AppRoute.profile);
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // simple local storage: update the favorites store if available
    if (_isFavorite) {
      _localFavorites.restaurantIds.add(widget.restaurant.id);
    } else {
      _localFavorites.restaurantIds.remove(widget.restaurant.id);
    }
  }

  @override
  void initState() {
    super.initState();
    // Ask the RestaurantBloc to load the menu for this restaurant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final slug = widget.restaurant.slug;
      context.read<RestaurantBloc>().add(LoadMenu(restaurantSlug: slug));
    });
  }

  List<restmodels.Restaurant> get allRestaurants => [widget.restaurant];

  List<itemmodels.Item> get allDishes {
    if (_menu == null) return [];
    return _menu!.items;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        if (state is RestaurantError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Menu'),
              backgroundColor: AppColors.primaryColor,
            ),
            body: Center(child: Text('Failed to load menu: ${state.message}')),
          );
        }

        if (state is MenuLoaded) {
          // initialize menu once
          _menu ??= state.menu;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _buildRestaurantHeader(),
                  // Render menu items as a simple list (Menu.items exists in domain)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: _menu!.items.length,
                      itemBuilder: (context, index) {
                        final item = _menu!.items[index];
                        return _buildMenuItem(item);
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavBar(
              selectedTab: BottomNavTab.explore,
              onTabSelected: _onTabSelected,
            ),
          );
        }

        // default fallback
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantHeader() {
    // If you later add a real banner image to your model, use it here.
    const String bannerUrl =
        'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=889&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'; // fallback

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner + overlays
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner image
              ClipRRect(
                child: Image.network(
                  bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[300]),
                ),
              ),

              // Bottom gradient for text readability
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),

              // Top actions (back / share)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleIcon(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      _circleIcon(icon: Icons.share_outlined, onTap: () {}),
                    ],
                  ),
                ),
              ),

              // Name + subtitle (bottom-left)
              const Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Addis Red Sea',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Traditional Ethiopian cuisine',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Floating info card overlapping the banner bottom
        Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildRestaurantInfoCard(),
          ),
        ),

        const SizedBox(height: 4),

        // Digital Menu row (kept as-is, just placed after the card)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Digital Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                icon: const Icon(Icons.translate_rounded, color: Colors.white),
                onPressed: () {},
                label: const Text(
                  'Translate',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRestaurantInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Expanded(child: Text('Bole Atlas, Addis Ababa')),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Expanded(child: Text('Open: 11:00 AM - 10:00 PM')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                const Text(
                  '4.8',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                const Text('(142 reviews)'),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }

  // TabBar removed; menu now renders as a simple list using Menu.items
  Widget _buildMenuItem(itemmodels.Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailsPage(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.images != null && item.images!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  item.images![0],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Icon(Icons.restaurant, color: Colors.grey),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${item.price.toStringAsFixed(0)} ${item.currency}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
