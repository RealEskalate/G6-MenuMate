import 'package:flutter/material.dart';
import '../widgets/owner_navbar.dart';
import '../widgets/settings_item.dart';
import '../../../../../core/util/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SettingsItem(
            title: 'Restaurant profile',
            leadingIcon: Icons.restaurant,
            iconColor: AppColors.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, '/restaurant_profile');
            },
          ),
          
          SettingsItem(
            title: 'User profile',
            leadingIcon: Icons.person,
            iconColor: AppColors.primaryColor,
            onTap: () {
              // Navigate to user profile page
            },
          ),
          
          SettingsItem(
            title: 'Legal info',
            leadingIcon: Icons.gavel,
            iconColor: AppColors.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, '/legal_info');
            },
          ),
          
          SettingsItem(
            title: 'Branding & Menu preferences',
            leadingIcon: Icons.palette,
            iconColor: AppColors.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, '/branding_preferences');
            },
          ),
          
          SettingsItem(
            title: 'Billing',
            leadingIcon: Icons.payment,
            iconColor: AppColors.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, '/billing');
            },
          ),
          
        ],
      ),
      bottomNavigationBar:
          const OwnerNavBar(currentIndex: 4, isRestaurantOwner: true),
    );
  }
}
