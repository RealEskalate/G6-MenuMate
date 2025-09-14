import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
// import '../../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
// import '../../../../restaurant_management/presentation/bloc/restaurant_event.dart';
// import '../../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../../../../../injection_container.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../widgets/button.dart';
import '../widgets/owner_navbar.dart';
import '../widgets/rest_menu_card.dart';
// For navigation, if needed

class MenusPage extends StatelessWidget {
  final String restaurantSlug;
  const MenusPage({super.key, required this.restaurantSlug});

  void _showDigitizeMenuDialog(BuildContext context) {
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
                  label: 'Scan with\nOCR',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/digitize-menu');
                  },
                ),
                const SizedBox(width: 18),
                DigitizeMenuButton(
                  icon: Icons.edit_document,
                  label: 'Create\nmanually',
                  onTap: () async {
                    Navigator.pop(context); // close dialog
                    await Future.delayed(const Duration(milliseconds: 100));
                    Navigator.pushNamed(
                      context,
                      '/create-menu-manually',
                      arguments: {'restaurantId': restaurantSlug},
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
    return BlocProvider<MenuBloc>(
      create: (_) =>
          sl<MenuBloc>()..add(LoadMenuEvent(restaurantSlug: restaurantSlug)),
      child: Scaffold(
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
                    onPressed: () => _showDigitizeMenuDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<MenuBloc, MenuState>(
                  builder: (context, state) {
                    if (state is MenuLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MenuLoaded) {
                      final menus = state.menu.items;
                      return ListView.builder(
                        itemCount: menus.length,
                        itemBuilder: (context, idx) {
                          final tab = menus[idx];
                          return RestMenuCard(
                            tab: tab,
                            isPublished: state.menu.isPublished,
                          );
                        },
                      );
                    } else if (state is MenuError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.red),
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
        bottomNavigationBar: OwnerNavBar(
          isRestaurantOwner: true,
          currentIndex: 3,
          restaurantId: restaurantSlug,
        ),
      ),
    );
  }
}

// Separate widget for the digitize menu button
