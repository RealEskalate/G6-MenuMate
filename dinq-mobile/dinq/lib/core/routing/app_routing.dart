import 'package:flutter/material.dart';

import '../../features/dinq/qr_scanner/pages/qr_scanner_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/billing_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/branding_preferences_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/legal_info_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/opening_hours_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/restaurant_details_page.dart';
// restaurant management pages
import '../../features/dinq/restaurant_management/presentation/pages/restaurant_profile_page.dart';
import '../../features/dinq/search/presentation/pages/favourites_page.dart';
import '../../features/dinq/search/presentation/pages/home_page.dart';
import '../../features/dinq/search/presentation/pages/item_details_page.dart';
import '../../features/dinq/search/presentation/pages/profile_page.dart';
import '../../features/dinq/search/presentation/pages/restaurant_page.dart';
import '../../features/dinq/search/presentation/pages/scanned_menu_page.dart';

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

    // restaurant management routes (added from main.dart)
    case '/restaurant_profile':
      return MaterialPageRoute(builder: (_) => const RestaurantProfilePage());
    case '/restaurant_details':
      return MaterialPageRoute(builder: (_) => const RestaurantDetailsPage());
    case '/opening_hours':
      return MaterialPageRoute(builder: (_) => const OpeningHoursPage());
    case '/legal_info':
      return MaterialPageRoute(builder: (_) => const LegalInfoPage());
    case '/branding_preferences':
      return MaterialPageRoute(builder: (_) => const BrandingPreferencesPage());
    case '/billing':
      return MaterialPageRoute(builder: (_) => const BillingPage());
    case '/qrcode':
      return MaterialPageRoute(builder: (_) => const QrScannerPage());
    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Page not found'))),
      );
  }
}
