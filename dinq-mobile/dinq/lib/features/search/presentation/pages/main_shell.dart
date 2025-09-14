import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/user_bloc.dart';
import '../../../auth/presentation/bloc/user_state.dart';
import '../../../restaurant_management/domain/entities/item.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/pages/analytics_page.dart';
import '../../../restaurant_management/presentation/pages/menus_page.dart';
import '../../../restaurant_management/presentation/pages/settings_page.dart';
import 'favourites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  final String? restaurantId;
  final int initialIndex;

  const MainShell({
    super.key,
    this.restaurantId,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        print('DEBUG: MainShell state: $state');
        bool isOwner = false;
        if (state is UserLoggedIn && state.user.role == 'owner') {
          isOwner = true;
          print('DEBUG: User is owner');
        } else if (state is UserRegistered && state.user.role == 'owner') {
          isOwner = true;
          print('DEBUG: UserRegistered is owner');
        } else if (state is AuthChecked &&
            state.user != null &&
            state.user!.role == 'owner') {
          isOwner = true;
          print('DEBUG: AuthChecked user is owner');
        }
        print('DEBUG: isOwner: $isOwner');

        final pages = isOwner
            ? [
                const HomePage(),
                const FavouritesPage(
                    allRestaurants: <Restaurant>[],
                    allDishes: <Item>[],
                    showOwnerNavBar: false),
                const AnalyticsPage(),
                MenusPage(restaurantSlug: widget.restaurantId ?? ''),
                const SettingsPage(),
              ]
            : [
                const HomePage(),
                const FavouritesPage(
                    allRestaurants: <Restaurant>[],
                    allDishes: <Item>[],
                    showOwnerNavBar: false),
                const ProfilePage(showOwnerNavBar: false),
              ];

        final navItems = isOwner
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
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ];

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: navItems,
          ),
        );
      },
    );
  }
}
