import 'package:flutter/material.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../search/presentation/pages/customer/customer_favorites_page.dart';
import '../../../search/presentation/pages/customer/customer_home_page.dart';
import '../../../search/presentation/pages/customer/customer_profile_page.dart';

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
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>CustomerHomePage()));
        break;

      case 1:
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>CustomerFavoritesPage()));
        break;

      case 2:
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>CustomerProfilePage()));
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