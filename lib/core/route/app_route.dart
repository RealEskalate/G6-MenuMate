import 'package:dinq/features/qr_menu/presentaion/pages/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:dinq/features/qr_menu/presentaion/pages/qr_scanner_page.dart';

class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('Navigating to route: ${settings.name}');
    switch (settings.name) {
      case '/qr_scanner':
        return MaterialPageRoute(builder: (_) => const QrScannerPage());
      case '/menu_page':
        final branchId = settings.arguments as String?;
        if (branchId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Branch ID is missing')),
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => MenuPage(branchId: branchId));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route defined for this page')),
          ),
        );
    }
  }
}
