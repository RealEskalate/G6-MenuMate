import 'package:flutter/material.dart';

import '../../features/dinq/auth/presentation/Pages/login_page.dart';
import '../../features/dinq/auth/presentation/Pages/onboarding_first.dart';
import '../../features/dinq/qr_scanner/pages/qr_scanner_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/analytics_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/billing_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/branding_preferences_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/create_menu_manually_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/digitize_menu_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/edit_menu_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/edit_menu_item_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/edit_single_menu_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/edit_uploaded_menu_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/generated_qr_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/legal_info_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/menus_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/opening_hours_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/qr_customization_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/restaurant_details_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/restaurant_profile_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/settings_page.dart';
import '../../features/dinq/search/presentation/pages/favourites_page.dart';
import '../../features/dinq/search/presentation/pages/home_page.dart';
import '../../features/dinq/search/presentation/pages/item_details_page.dart';
import '../../features/dinq/search/presentation/pages/profile_page.dart';
import '../../features/dinq/search/presentation/pages/restaurant_page.dart';
import '../../features/dinq/search/presentation/pages/scanned_menu_page.dart';

class AppRoute {
  // Search routes
  static const String onboarding = '/onboarding';
  static const String explore = '/explore';
  static const String favorites = '/favorites';
  static const String home = '/home';
  static const String itemDetail = '/item-detail';
  static const String restaurant = '/restaurant';
  static const String scannedMenu = '/scanned-menu';
  static const String profile = '/profile';

  // Restaurant management routes
  static const String restaurantProfile = '/restaurant_profile';
  static const String restaurantDetails = '/restaurant_details';
  static const String openingHours = '/opening_hours';
  static const String legalInfo = '/legal_info';
  static const String brandingPreferences = '/branding_preferences';
  static const String billing = '/billing';
  static const String qrcode = '/qrcode';
  static const String setting = '/settings';

  // Menu management routes
  static const String qrcustomization = '/qrcustom';
  static const String menus = '/menus';
  static const String editMenu = '/edit-menu';
  static const String editSingleMenu = '/edit-single-menu';
  static const String createMenuManually = '/create-menu-manually';
  static const String editUploadedMenu = '/edit-uploaded-menu';
  static const String generatedQr = '/generated-qr';
  static const String analytics = '/analytics';
  static const String digitizeMenu = '/digitize-menu';
  static const String editMenuItem = '/edit-menu-item';
  static const String login = '/login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingFirst());
      case explore:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case favorites:
        return MaterialPageRoute(
          builder: (_) => const FavouritesPage(
            allRestaurants: [], // Pass your data here
            allDishes: [],
          ),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case itemDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final item = args['item'];
        return MaterialPageRoute(builder: (_) => ItemDetailsPage(item: item));
      case restaurant:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final restaurantId = args['restaurantId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => RestaurantPage(restaurantId: restaurantId),
        );
      case scannedMenu:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final slug = args['slug'] as String? ?? 'default-menu';
        return MaterialPageRoute(builder: (_) => ScannedMenuPage(slug: slug));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      // Restaurant management routes
      case restaurantProfile:
        return MaterialPageRoute(builder: (_) => const RestaurantProfilePage());
      case restaurantDetails:
        return MaterialPageRoute(builder: (_) => const RestaurantDetailsPage());
      case openingHours:
        return MaterialPageRoute(builder: (_) => const OpeningHoursPage());
      case legalInfo:
        return MaterialPageRoute(builder: (_) => const LegalInfoPage());
      case brandingPreferences:
        return MaterialPageRoute(
            builder: (_) => const BrandingPreferencesPage());
      case billing:
        return MaterialPageRoute(builder: (_) => const BillingPage());
      case qrcode:
        return MaterialPageRoute(builder: (_) => const QrScannerPage());
      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      // Menu management routes
      case menus:
        final args = settings.arguments as Map<String, dynamic>?;
        final restaurantId = args?['restaurantId'] ?? '';
        return MaterialPageRoute(
          builder: (_) => MenusPage(restaurantId: restaurantId),
        );
      // QrCustomizationPage

      case editMenu:
        return MaterialPageRoute(builder: (_) => const EditMenuPage());
      case qrcustomization:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => QrCustomizationPage(
            menuId: args?['menuId'],
            restaurantSlug: args?['restaurantSlug'] ?? 'the-italian-corner-4b144298',
          ),
        );
      case editSingleMenu:
        // Pass menuData as arguments if needed
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditSingleMenuPage(menuData: args ?? {}),
        );
      case createMenuManually:
        return MaterialPageRoute(
          builder: (_) => const CreateMenuManuallyPage(restaurantId: 'dummy'),
        );
      case editMenuItem:
        // Pass itemData as arguments if needed
        final args = settings.arguments as Map<String, dynamic>?;
        // If you want to pass data, update EditMenuItemPage constructor accordingly
        return MaterialPageRoute(
          builder: (_) => EditMenuItemPage(item: args?['item']),
        );
      case editUploadedMenu:
        // Pass uploadedImage and menuSections as arguments if needed
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditUploadedMenuPage(
            uploadedImage: args?['uploadedImage'],
            // Pass other args as needed
          ),
        );
      case generatedQr:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              GeneratedQrPage(qrImagePath: args?['qrImagePath'] ?? ''),
        );
      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsPage());
      case digitizeMenu:
        return MaterialPageRoute(builder: (_) => const DigitizeMenuPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
