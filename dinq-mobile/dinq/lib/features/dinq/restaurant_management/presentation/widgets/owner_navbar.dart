import 'package:flutter/material.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';

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
          Navigator.pushReplacementNamed(context, AppRoute.explore);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, AppRoute.favorites);
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
          Navigator.pushReplacementNamed(context, AppRoute.setting);
          break;
      }
    } else {
      switch(index){
        case 0:
          Navigator.pushReplacementNamed(context, AppRoute.explore);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, AppRoute.favorites);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, AppRoute.profile);
          break;
      }
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile'),
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
