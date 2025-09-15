import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../bloc/restaurant_management_bloc.dart';
import '../bloc/restaurant_management_event.dart';
import '../bloc/restaurant_management_state.dart';
import '../widgets/settings_item.dart';
import 'restaurant_details_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantManagementBloc, RestaurantManagementState>(
        builder: (context, state) {
      // Automatically load owner restaurants if not loaded yet
      if (state is RestaurantManagementInitial ||
          (state is! OwnerRestaurantsLoaded &&
              state is! RestaurantManagementLoading)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context
              .read<RestaurantManagementBloc>()
              .add(const LoadOwnerRestaurants());
        });
      }

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
              title: 'Restaurant Details',
              leadingIcon: Icons.restaurant,
              iconColor: AppColors.primaryColor,
              onTap: () {
                if (state is OwnerRestaurantsLoaded) {
                  if (state.selectedRestaurant != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailsPage(
                            restaurant: state.selectedRestaurant!),
                      ),
                    );
                  } else if (state.restaurants.isNotEmpty) {
                    // Auto-select the first restaurant
                    context
                        .read<RestaurantManagementBloc>()
                        .add(SelectRestaurant(state.restaurants.first));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Selected your restaurant. Tap again to view details.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'No restaurants found. Please create a restaurant first.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Loading restaurants...')),
                  );
                }
              },
            ),
            SettingsItem(
              title: 'User profile',
              leadingIcon: Icons.person,
              iconColor: AppColors.primaryColor,
              onTap: () {
                Navigator.pushNamed(context, '/profile');
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
      );
    });
  }
}
