import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../../../../../core/routing/app_route.dart';

class NearbyRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const NearbyRestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        minLeadingWidth: 0,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              restaurant.logoImage != null && restaurant.logoImage!.isNotEmpty
                  ? Image.network(
                      restaurant.logoImage!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/food.png',
                          width: 56,
                          height: 56),
                    )
                  : Image.asset(
                      'assets/images/food.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
        ),
        title: Text(restaurant.restaurantName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            restaurant.tags == null || restaurant.tags!.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    restaurant.tags!.take(2).join(' • '),
                    style: const TextStyle(fontSize: 13),
                  ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 2),
                Text(
                  '${restaurant.averageRating}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  '${restaurant.viewCount}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: BlocListener<RestaurantBloc, RestaurantState>(
          listener: (context, state) {
            if (state is MenuLoaded) {
              Navigator.pushNamed(
                context,
                AppRoute.restaurant,
                arguments: {
                  'restaurant': restaurant,
                  'menu': state.menu,
                },
              );
            }
          },
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            onPressed: () {
              context.read<RestaurantBloc>().add(LoadMenu(restaurant.slug));
            },
            child: const Text('View Menu'),
          ),
        ),
      ),
    );
  }
}
