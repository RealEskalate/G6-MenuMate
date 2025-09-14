import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../../../auth/presentation/bloc/user_bloc.dart';
import '../../../auth/presentation/bloc/user_event.dart';
import '../../../restaurant_management/domain/entities/item.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/bloc/menu_bloc.dart';
import '../../../restaurant_management/presentation/bloc/menu_event.dart';
import '../../../restaurant_management/presentation/bloc/menu_state.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import 'item_details_page.dart';

class RestaurantPage extends StatefulWidget {
  final String restaurantSlug;
  const RestaurantPage({super.key, required this.restaurantSlug});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  bool _menuLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load restaurant details first
    _loadRestaurant();
  }

  void _loadRestaurant() {
    final slug = widget.restaurantSlug;
    context.read<RestaurantBloc>().add(LoadRestaurantBySlug(slug));
  }

  void _loadMenu(String restaurantSlug) {
    if (!_menuLoaded) {
      _menuLoaded = true;
      context
          .read<MenuBloc>()
          .add(LoadMenuEvent(restaurantSlug: restaurantSlug));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RestaurantBloc, RestaurantState>(
          builder: (context, restaurantState) {
            // Header can be built from loaded restaurant state; fallback to empty container
            Widget header;
            Restaurant? restaurant;
            if (restaurantState is RestaurantLoaded) {
              restaurant = restaurantState.restaurant;
              header = _buildRestaurantHeader(restaurant);
              // Load menu after restaurant is successfully loaded
              _loadMenu(widget.restaurantSlug);
            } else if (restaurantState is RestaurantLoading) {
              header = Container();
            } else if (restaurantState is RestaurantError) {
              header = Container();
            } else {
              header = Container();
            }

            return Column(
              children: [
                header,
                Expanded(
                  child: BlocBuilder<MenuBloc, MenuState>(
                    builder: (context, menuState) {
                      Widget menuChild;
                      if (restaurantState is RestaurantLoading) {
                        menuChild =
                            const Center(child: CircularProgressIndicator());
                      } else if (restaurantState is RestaurantError) {
                        menuChild =
                            Center(child: Text(restaurantState.message));
                      } else if (menuState is MenuLoading) {
                        menuChild =
                            const Center(child: CircularProgressIndicator());
                      } else if (menuState is MenuLoaded) {
                        final menu = menuState.menu;
                        final items = menu.items;
                        if (items.isEmpty) {
                          menuChild =
                              const Center(child: Text('No menu items'));
                        } else {
                          menuChild = ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final item = items[idx];
                              return _buildMenuItem(item);
                            },
                          );
                        }
                      } else if (menuState is MenuError) {
                        menuChild = Center(child: Text(menuState.message));
                      } else {
                        menuChild = const Center(child: Text('No menu'));
                      }

                      return menuChild;
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader(Restaurant restaurant) {
    // Fallback cover image
    String bannerUrl = restaurant.coverImage ??
        'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=889&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[300]),
              ),

              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),

              // Top actions
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
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

              // Restaurant name
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.restaurantName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Traditional Ethiopian cuisine',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Info card
        Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildRestaurantInfoCard(),
          ),
        ),

        const SizedBox(height: 4),

        // Menu header row
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

  Widget _buildMenuItem(Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (item.images != null && item.images!.isNotEmpty)
              ? Image.network(
                  item.images!.first,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
                )
              : Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? Text(
                item.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              )
            : null,
        trailing: Text(
          '${item.price.toStringAsFixed(0)} ${item.currency}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.primaryColor),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ItemDetailsPage(item: item)),
          );
        },
      ),
    );
  }

  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to favorites!')),
    );
    context.read<UserBloc>().add(SaveFavoriteRestaurantIdsEvent(id: widget.restaurantSlug));
  }
}
