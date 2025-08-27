import 'package:flutter/material.dart';
import 'core/route/app_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dineq',
      initialRoute: '/qr_scanner',
      onGenerateRoute: AppRoute.generateRoute,
    );
  }
}
