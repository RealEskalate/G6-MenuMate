import 'package:flutter/material.dart';

import '../../features/auth/presentation/Pages/login_page.dart';
import '../../features/auth/presentation/Pages/manger_registration.dart';
import '../../features/auth/presentation/Pages/onboarding_first.dart';
import '../../features/auth/presentation/Pages/onboarding_second.dart';
import '../../features/auth/presentation/Pages/onboarding_third.dart';
import '../../features/auth/presentation/Pages/resturant_data.dart';
import '../../features/auth/presentation/Pages/resturant_registration.dart';
import '../../features/auth/presentation/Pages/user_register.dart';
import '../../features/qr_scanner/pages/qr_scanner_page.dart';
import '../../features/restaurant_management/domain/entities/restaurant.dart';
import '../../features/restaurant_management/presentation/pages/billing_page.dart';
import '../../features/restaurant_management/presentation/pages/branding_preferences_page.dart';
import '../../features/restaurant_management/presentation/pages/create_menu_manually_page.dart';
import '../../features/restaurant_management/presentation/pages/digitize_menu_page.dart';
import '../../features/restaurant_management/presentation/pages/edit_menu_page.dart';
import '../../features/restaurant_management/presentation/pages/edit_single_menu_page.dart';
import '../../features/restaurant_management/presentation/pages/generated_qr_page.dart';
import '../../features/restaurant_management/presentation/pages/legal_info_page.dart';
import '../../features/restaurant_management/presentation/pages/qr_customization_page.dart';
import '../../features/restaurant_management/presentation/pages/restaurant_details_page.dart';
import '../../features/restaurant_management/presentation/pages/restaurant_profile_page.dart';
import '../../features/search/presentation/pages/main_shell.dart';
import '../../features/search/presentation/pages/restaurant_page.dart';

class AppRoute {
  // Auth routes
  static const String onboardingFirst = '/onboarding_first';
  static const String onboardingSecond = '/onboarding_second';
  static const String onboardingThird = '/onboarding_third';
  static const String userRegister = '/user_register';
  static const String managerRegister = '/manager_register';
  static const String restaurantRegister = '/restaurant_register';
  static const String restaurantData = '/restaurant_Data';

  // Search routes
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
  static const String mainShell = '/mainShell';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case onboardingFirst:
        return MaterialPageRoute(builder: (_) => const OnboardingFirst());
      case onboardingSecond:
        return MaterialPageRoute(builder: (_) => const OnboardingSecond());
      case onboardingThird:
        return MaterialPageRoute(builder: (_) => const OnboardingThird());
      case userRegister:
        return MaterialPageRoute(builder: (_) => const UserRegister());
      case managerRegister:
        return MaterialPageRoute(builder: (_) => const ManagerRegistration());
      case restaurantRegister:
        return MaterialPageRoute(
            builder: (_) => const RestaurantRegistration());

      case restaurantData:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => RestaurantData(
                  name: args['name'],
                  phoneNumber: args['phoneNumber'],
                  document: args['document'],
                ));
      case mainShell:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => MainShell(
            restaurantId: args['restaurantId'],
            initialIndex: args['initialIndex'] ?? 0,
          ),
        );
      case explore:
        return MaterialPageRoute(
          builder: (_) => const MainShell(
            initialIndex: 0,
          ),
        );
      case favorites:
        return MaterialPageRoute(
          builder: (_) => const MainShell(
            initialIndex: 1,
          ),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const MainShell(
            initialIndex: 2,
          ),
        );
      case analytics:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => MainShell(
            initialIndex: 2,
            restaurantId: args['restaurantId'],
          ),
        );
      case menus:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => MainShell(
            initialIndex: 3,
            restaurantId: args['restaurantId'],
          ),
        );
      case setting:
        return MaterialPageRoute(
          builder: (_) => const MainShell(
            initialIndex: 4,
          ),
        );
      case restaurant:
        return MaterialPageRoute(
            builder: (_) =>
                RestaurantPage(restaurantSlug: settings.arguments as String));
      // Restaurant management routes
      case restaurantProfile:
        return MaterialPageRoute(builder: (_) => const RestaurantProfilePage());
      case restaurantDetails:
        return MaterialPageRoute(
            builder: (_) => RestaurantDetailsPage(
                restaurant: settings.arguments as Restaurant));
      case legalInfo:
        return MaterialPageRoute(builder: (_) => const LegalInfoPage());
      case brandingPreferences:
        return MaterialPageRoute(
            builder: (_) => const BrandingPreferencesPage());
      case billing:
        return MaterialPageRoute(builder: (_) => const BillingPage());
      case qrcode:
        return MaterialPageRoute(builder: (_) => const QrScannerPage());

      // Menu management routes
      case editMenu:
        return MaterialPageRoute(builder: (_) => const EditMenuPage());
      case qrcustomization:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => QrCustomizationPage(
            menuId: args?['menuId'],
            restaurantSlug:
                args?['restaurantSlug'] ?? 'the-italian-corner-4b144298',
          ),
        );
      case editSingleMenu:
        // Pass menuData as arguments if needed
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditSingleMenuPage(menuData: args ?? {}),
        );
      case createMenuManually:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateMenuManuallyPage(
            restaurantId: args?['restaurantId'] ?? 'dummy',
            parsedMenuData: args?['parsedMenuData'],
          ),
        );
      // case editMenuItem:
      //   // Pass itemData as arguments if needed
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   // If you want to pass data, update EditMenuItemPage constructor accordingly
      //   return MaterialPageRoute(
      //     builder: (_) => EditMenuItemPage(item: args?['item']),
      //   );
      // case editUploadedMenu:
      //   // Pass uploadedImage and menuSections as arguments if needed
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => EditUploadedMenuPage(
      //       uploadedImage: args?['uploadedImage'],
      //       // Pass other args as needed
      //     ),
      //   );
      case generatedQr:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              GeneratedQrPage(qrImagePath: args?['qrImagePath'] ?? ''),
        );
      case digitizeMenu:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DigitizeMenuPage(
            restaurantId: args?['restaurantId'] ?? 'dummy',
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
