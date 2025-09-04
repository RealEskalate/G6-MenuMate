import 'package:flutter/material.dart';

import '../../features/dinq/restaurant_management/presentation/pages/analytics_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/create_menu_manually_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/digitize_menu_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/edit_menu_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/edit_menu_item_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/edit_single_menu_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/edit_uploaded_menu_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/generated_qr_page.dart';
import '../../features/dinq/restaurant_management/presentation/pages/menus_page.dart';

class AppRoute {
  static const String menus = '/menus';
  static const String editMenu = '/edit-menu';
  static const String editSingleMenu = '/edit-single-menu';
  static const String createMenuManually = '/create-menu-manually';
  static const String editUploadedMenu = '/edit-uploaded-menu';
  static const String generatedQr = '/generated-qr';
  static const String analytics = '/analytics';
  static const String digitizeMenu = '/digitize-menu';
  static const String editMenuItem = '/edit-menu-item';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case menus:
        final args = settings.arguments as Map<String, dynamic>?;
        final restaurantId = args?['restaurantId'] ?? '';
        return MaterialPageRoute(
          builder: (_) => MenusPage(restaurantId: restaurantId),
        );
      case editMenu:
        return MaterialPageRoute(builder: (_) => const EditMenuPage());
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
