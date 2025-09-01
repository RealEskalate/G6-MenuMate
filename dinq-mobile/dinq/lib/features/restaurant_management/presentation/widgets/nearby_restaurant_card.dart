import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../domain/entities/restaurant.dart';

class NearbyRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final String? distance;
  final double? rating;
  final int? reviews;
  final VoidCallback? onViewMenu;

  const NearbyRestaurantCard({
    super.key,
    required this.restaurant,
    this.distance,
    this.rating,
    this.reviews,
    this.onViewMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        minLeadingWidth: 0,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            restaurant.image,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${restaurant.description} \u2022 ${distance ?? '—'}',
              style: const TextStyle(fontSize: 13),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 2),
                Text(
                  '${(rating ?? 0).toString()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${reviews ?? 0})',
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
          onPressed: onViewMenu,
          child: const Text('View Menu'),
        ),
      ),
    );
  }
}
