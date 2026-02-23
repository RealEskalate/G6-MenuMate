import 'package:flutter/material.dart';

import '../../../../restaurant_management/presentation/widgets/customer_navbar.dart';
import '../shared/home_page.dart';
class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomePage(),
      bottomNavigationBar: CustomerNavBar(currentIndex: 0),
    );
  }
}