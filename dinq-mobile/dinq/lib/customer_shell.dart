import 'package:flutter/material.dart';

import 'features/dinq/restaurant_management/presentation/widgets/customer_navbar.dart';
import 'features/dinq/search/presentation/pages/shared/home_page.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomePage(), // default page
      bottomNavigationBar: const CustomerNavBar(
        currentIndex: 0, // Explore tab
      ),
    );
  }
}