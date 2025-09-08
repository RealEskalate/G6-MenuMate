import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';

enum BottomNavTab { explore, favorites, profile, owner }

class BottomNavBar extends StatelessWidget {
  final BottomNavTab selectedTab;
  final ValueChanged<BottomNavTab> onTabSelected;

  final bool showOwnerTab;

  const BottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.showOwnerTab = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(
            icon: Icons.explore,
            label: 'Explore',
            tab: BottomNavTab.explore,
          ),
          _buildNavBarItem(
            icon: Icons.favorite,
            label: 'Favorites',
            tab: BottomNavTab.favorites,
          ),
          _buildNavBarItem(
            icon: Icons.person_outline,
            label: 'Profile',
            tab: BottomNavTab.profile,
          ),
          if (showOwnerTab)
            _buildNavBarItem(
              icon: Icons.storefront,
              label: 'Manage',
              tab: BottomNavTab.owner,
            ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required String label,
    required BottomNavTab tab,
  }) {
    final isSelected = selectedTab == tab;
    return GestureDetector(
      onTap: () => onTabSelected(tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryColor : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
