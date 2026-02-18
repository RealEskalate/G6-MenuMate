import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String cuisine;
  final String distance;
  final double rating;
  final int reviews;
  final String time;
  final VoidCallback? onViewMenu;

  const RestaurantCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.cuisine,
    required this.distance,
    required this.rating,
    required this.reviews,
    this.time = '',
    this.onViewMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bigger Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 100, // wider
              height: 100, // taller
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.restaurant, color: Colors.grey, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name, cuisine, rating and button column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // larger font
                  ),
                ),
                const SizedBox(height: 4),

                // Cuisine / Distance / Time row
                Row(
                  children: [
                    Text(
                      cuisine,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (distance.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 6),
                      Text(
                        distance,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                    if (time.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            time,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Rating badge + View Menu button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rating badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviews)',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // Small View Menu button next to rating
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6), // smaller
                        elevation: 0,
                      ),
                      onPressed: onViewMenu,
                      child: const Text(
                        'View Menu',
                        style: TextStyle(fontSize: 12), // smaller text
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
