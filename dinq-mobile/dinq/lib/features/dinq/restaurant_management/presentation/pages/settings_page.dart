import 'package:flutter/material.dart';
import '../widgets/settings_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SettingsItem(
            title: 'Restaurant profile',
            leadingIcon: Icons.restaurant,
            onTap: () {
                Navigator.pushNamed(context, '/restaurant_profile');
              },
          ),
          const Divider(),
          SettingsItem(
            title: 'User profile',
            leadingIcon: Icons.person,
            onTap: () {
              // Navigate to user profile page
            },
          ),
          const Divider(),
          SettingsItem(
            title: 'Legal info',
            leadingIcon: Icons.gavel,
            onTap: () {
                Navigator.pushNamed(context, '/legal_info');
              },
          ),
          const Divider(),
          SettingsItem(
            title: 'Branding & Menu preferences',
            leadingIcon: Icons.palette,
            onTap: () {
              Navigator.pushNamed(context, '/branding_preferences');
            },
          ),
          const Divider(),
          SettingsItem(
            title: 'Billing',
            leadingIcon: Icons.payment,
            onTap: () {
              Navigator.pushNamed(context, '/billing');
            },
          ),
          const Divider(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 4, // Settings tab
      ),
    );
  }
}