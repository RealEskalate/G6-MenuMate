import 'package:flutter/material.dart';
import '../widgets/settings_item.dart';

class RestaurantProfilePage extends StatelessWidget {
  const RestaurantProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SettingsItem(
            title: 'Restaurant details',
            leadingIcon: Icons.restaurant_menu,
            onTap: () {
              Navigator.pushNamed(context, '/restaurant_details');
            },
          ),
          const Divider(),
          SettingsItem(
            title: 'Opening and closing hours',
            leadingIcon: Icons.access_time,
            onTap: () {
              Navigator.pushNamed(context, '/opening_hours');
            },
          ),
          const Divider(),
        ],
      ),
      
    );
  }
}
