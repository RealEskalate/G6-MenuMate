
import 'package:flutter/material.dart';

import '../../features/restaurant_management/presentation/pages/favourites_page.dart';
import '../../features/restaurant_management/presentation/pages/home_page.dart';
import '../../features/restaurant_management/presentation/pages/item_details_page.dart';
import '../../features/restaurant_management/presentation/pages/profile_page.dart';
import '../../features/restaurant_management/presentation/pages/restaurant_page.dart';
import '../../features/restaurant_management/presentation/pages/scanned_menu_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/explore':
      return MaterialPageRoute(builder: (_) => const HomePage());
    case '/favorites':
      return MaterialPageRoute(
        builder: (_) => const FavouritesPage(
          allRestaurants: [], // Pass your data here
          allDishes: [],
        ),
      );
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomePage());

    case '/item-detail':
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      final item = args['item'];
      return MaterialPageRoute(builder: (_) => ItemDetailsPage(item: item));
    case '/restaurant':
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      final restaurantId = args['restaurantId'] as String? ?? '';
      return MaterialPageRoute(
        builder: (_) => RestaurantPage(restaurantId: restaurantId),
      );
    case '/scanned-menu':
      return MaterialPageRoute(builder: (_) => const ScannedMenuPage());
    
    case '/profile':
      return MaterialPageRoute(builder: (_) => const ProfilePage());
    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Page not found'))),
      );
  }
}
