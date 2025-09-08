import 'package:flutter/material.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';

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
          child: Image.network(
            restaurant.logoImage ??
                'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(restaurant.restaurantName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restaurant.tags != null && restaurant.tags!.isNotEmpty)
              SizedBox(
                height: 20, // adjust as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurant.tags!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        restaurant.tags![index],
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    );
                  },
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                ),
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
                  '(${restaurant.viewCount})',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
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
            Navigator.pushNamed(
              context,
              AppRoute.restaurant,
              arguments: restaurant,
            );
          },
          child: const Text('View Menu'),
        ),
      ),
    );
  }
}
