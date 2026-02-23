import 'package:flutter/material.dart';

import '../../../../restaurant_management/presentation/widgets/customer_navbar.dart';
import '../shared/favourites_page.dart';

class CustomerFavoritesPage extends StatelessWidget {
  const CustomerFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FavouritesPage(),
      bottomNavigationBar: CustomerNavBar(currentIndex: 1),
    );
  }
}