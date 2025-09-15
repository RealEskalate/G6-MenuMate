import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../bloc/restaurant_management_bloc.dart';
import '../bloc/restaurant_management_event.dart';
import '../bloc/restaurant_management_state.dart';
import '../widgets/button.dart';
import '../widgets/rest_menu_card.dart';

class MenusPage extends StatelessWidget {
  const MenusPage({super.key});

  void _showAddMenuDialog(BuildContext context) {
    final bloc = context.read<RestaurantManagementBloc>();
    final state = bloc.state;
    final selectedRestaurant = bloc.selectedRestaurant;

    if (selectedRestaurant == null) {
      if (state is OwnerRestaurantsLoaded && state.restaurants.isNotEmpty) {
        // Auto-select the first restaurant
        bloc.add(SelectRestaurant(state.restaurants.first));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Selected your restaurant. Tap "Add menu" again.')),
        );
      } else if (state is OwnerRestaurantsLoaded && state.restaurants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'No restaurants found. Please create a restaurant first.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading restaurants...')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 28,
          horizontal: 18,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How do you want to create\nyour menu?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DigitizeMenuButton(
                  icon: Icons.document_scanner,
                  label: 'Upload printed\nmenu',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/digitize-menu');
                  },
                ),
                const SizedBox(width: 18),
                DigitizeMenuButton(
                  icon: Icons.edit_document,
                  label: 'Create from\nscratch',
                  onTap: () async {
                    Navigator.pop(context); // close dialog
                    await Future.delayed(const Duration(milliseconds: 100));
                    Navigator.pushNamed(
                      context,
                      '/edit-menu',
                      arguments: {'restaurantId': selectedRestaurant.id},
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.whiteColor,
            foregroundColor: AppColors.secondaryColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Menus',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.secondaryColor,
                  ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Restaurant selector
                if (state is OwnerRestaurantsLoaded &&
                    state.restaurants.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: state.selectedRestaurant?.id,
                      hint: const Text('Select Restaurant'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: state.restaurants.map((restaurant) {
                        return DropdownMenuItem<String>(
                          value: restaurant.id,
                          child: Text(restaurant.restaurantName),
                        );
                      }).toList(),
                      onChanged: (restaurantId) {
                        if (restaurantId != null) {
                          final restaurant = state.restaurants
                              .firstWhere((r) => r.id == restaurantId);
                          context
                              .read<RestaurantManagementBloc>()
                              .add(SelectRestaurant(restaurant));
                        }
                      },
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add menu'),
                      onPressed: () => _showAddMenuDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state is RestaurantManagementLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is RestaurantSelected) {
                        final menus = state.menus;
                        if (menus.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 80,
                                  color:
                                      AppColors.primaryColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No menus yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.secondaryColor,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first menu to get started',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.secondaryColor
                                            .withOpacity(0.7),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: AppColors.whiteColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add New Menu'),
                                  onPressed: () => _showAddMenuDialog(context),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: AppColors.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add menu'),
                                  onPressed: () => _showAddMenuDialog(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: menus.length,
                                itemBuilder: (context, idx) {
                                  final menu = menus[idx];
                                  return RestMenuCard(
                                    tab: menu,
                                    isPublished: menu.isPublished,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      } else if (state is RestaurantManagementError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.red),
                          ),
                        );
                      } else if (state is OwnerRestaurantsLoaded &&
                          state.selectedRestaurant == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 80,
                                color: AppColors.primaryColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select a restaurant',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AppColors.secondaryColor,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose a restaurant from the dropdown above to view and manage menus',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.secondaryColor
                                          .withOpacity(0.7),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Separate widget for the digitize menu button
