import 'package:flutter/material.dart';

import '../../../restaurant_management/domain/entities/item.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/pages/menus_page.dart';
import '../widgets/bottom_navbar.dart';
import 'favourites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  BottomNavTab _selected = BottomNavTab.explore;
  late final List<Widget> _pages;
  bool _showOwnerTab = false;

  @override
  void initState() {
    super.initState();
    // instantiate pages once so they preserve state when switching
    _pages = [
      const HomePage(),
      const FavouritesPage(
          allRestaurants: <Restaurant>[],
          allDishes: <Item>[],
          showOwnerNavBar: false),
      const ProfilePage(showOwnerNavBar: false),
    ];
    // MenusPage (owner tab) will be appended dynamically if needed
  }

  void _onTabSelected(BottomNavTab tab) {
    if (tab == _selected) return;
    setState(() => _selected = tab);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selected.index;

    // Ensure pages list matches owner tab visibility
    final pages = List<Widget>.from(_pages);
    if (_showOwnerTab) {
      if (pages.length < 4) pages.add(const MenusPage(restaurantSlug: ''));
    } else {
      if (pages.length > 3) pages.removeLast();
    }

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedTab: _selected,
        onTabSelected: _onTabSelected,
        showOwnerTab: _showOwnerTab,
      ),
    );
  }
}
