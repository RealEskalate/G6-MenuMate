import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String cuisine;
  final String distance;
  final double rating;
  final int reviews;
  final VoidCallback? onViewMenu;

  const RestaurantCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.cuisine,
    required this.distance,
    required this.rating,
    required this.reviews,
    this.onViewMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        // ensure leading has a fixed size to avoid layout warnings
        minLeadingWidth: 0,
        leading: SizedBox(
          width: 56,
          height: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (imageUrl.isNotEmpty &&
                    (imageUrl.startsWith('http://') ||
                        imageUrl.startsWith('https://')))
                ? Image.network(
                    imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child:
                            const Icon(Icons.restaurant, color: Colors.grey)),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant, color: Colors.grey)),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('$cuisine • $distance', style: const TextStyle(fontSize: 13)),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 2),
                Text(
                  '$rating',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  '($reviews)',
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
