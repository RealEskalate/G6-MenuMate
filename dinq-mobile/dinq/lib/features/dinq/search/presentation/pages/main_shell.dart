import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../auth/presentation/bloc/user_bloc.dart';
import '../../../auth/presentation/bloc/user_state.dart';
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
    // Initialize owner tab visibility based on current user state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = BlocProvider.of<UserBloc>(context).state;
      if (state is UserLoggedIn) {
        setState(
            () => _showOwnerTab = state.user.role.toLowerCase() == 'owner');
      } else if (state is UserRegistered) {
        setState(
            () => _showOwnerTab = state.user.role.toLowerCase() == 'owner');
      } else if (state is AuthChecked && state.user != null) {
        setState(
            () => _showOwnerTab = state.user!.role.toLowerCase() == 'owner');
      }
    });
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

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoggedIn) {
          setState(
              () => _showOwnerTab = state.user.role.toLowerCase() == 'owner');
        } else if (state is UserRegistered) {
          setState(
              () => _showOwnerTab = state.user.role.toLowerCase() == 'owner');
        } else if (state is UserLoggedOut) {
          setState(() => _showOwnerTab = false);
          // Redirect to home when user logs out
          Navigator.pushReplacementNamed(context, AppRoute.home);
        } else if (state is AuthChecked) {
          setState(() => _showOwnerTab =
              state.user != null && state.user!.role.toLowerCase() == 'owner');
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavBar(
          selectedTab: _selected,
          onTabSelected: _onTabSelected,
          showOwnerTab: _showOwnerTab,
        ),
      ),
    );
  }
}
