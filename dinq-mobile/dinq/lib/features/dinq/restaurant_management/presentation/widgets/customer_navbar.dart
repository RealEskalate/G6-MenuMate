import 'package:flutter/material.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';

class CustomerNavBar extends StatelessWidget {
  final int currentIndex; // which tab is active

  const CustomerNavBar({
    super.key,
    required this.currentIndex,
  });

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return; // already on this tab

    switch (index) {
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

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.secondaryColor.withOpacity(0.6),
      backgroundColor: AppColors.whiteColor,
      type: BottomNavigationBarType.fixed,
      onTap: (i) => _handleTap(context, i),
      items: const [
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
          label: 'Profile',
        ),
      ],
    );
  }
}