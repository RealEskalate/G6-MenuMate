import 'package:flutter/material.dart';

import '../../../../restaurant_management/presentation/widgets/customer_navbar.dart';
import '../shared/profile_page.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProfilePage(),
      bottomNavigationBar: CustomerNavBar(currentIndex: 2),
    );
  }
}