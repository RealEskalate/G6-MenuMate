import 'package:flutter/material.dart';
import '../../../../core/routing/app_route.dart';
import '../../../../core/util/theme.dart';

class OwnerNavBar extends StatelessWidget {
  final bool isRestaurantOwner;
  final int currentIndex; // 👈 NEW: which tab is active
  final String? restaurantId; // 👈 NEW: needed for Menus route

  const OwnerNavBar({
    super.key,
    this.isRestaurantOwner = true,
    required this.currentIndex,
    this.restaurantId,
  });

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return; // no-op if already on this tab

    if (isRestaurantOwner) {
      switch (index) {
        case 0:
          // TODO: implement Explore route when ready
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Explore not wired yet')),
          );
          break;
        case 1:
          // TODO: implement Favorites route when ready
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favorites not wired yet')),
          );
          break;
        case 2:
          Navigator.pushReplacementNamed(
            context,
            AppRoute.analytics,
            arguments: {'restaurantId': restaurantId ?? ''},
          );
          break;
        case 3:
          if ((restaurantId ?? '').isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Missing restaurantId for Menus')),
            );
            return;
          }
          Navigator.pushReplacementNamed(
            context,
            AppRoute.menus,
            arguments: {'restaurantId': restaurantId},
          );
          break;
        case 4:
          // TODO: implement Settings route when ready
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings not wired yet')),
          );
          break;
      }
    } else {
      // Non-owner nav handling (if/when you add it)
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = isRestaurantOwner
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Menus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.secondaryColor.withOpacity(0.6),
      backgroundColor: AppColors.whiteColor,
      type: BottomNavigationBarType.fixed,
      items: items,
      onTap: (i) => _handleTap(context, i),
    );
  }
}
