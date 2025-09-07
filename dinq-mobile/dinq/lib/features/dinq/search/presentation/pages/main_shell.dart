import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'home_page.dart';
import 'favourites_page.dart';
import 'profile_page.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/domain/entities/item.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  BottomNavTab _selected = BottomNavTab.explore;
  late final List<Widget> _pages;

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
  }

  void _onTabSelected(BottomNavTab tab) {
    if (tab == _selected) return;
    setState(() => _selected = tab);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selected.index;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedTab: _selected,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
