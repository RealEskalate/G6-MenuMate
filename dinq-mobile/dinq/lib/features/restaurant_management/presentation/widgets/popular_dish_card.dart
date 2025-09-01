import 'package:flutter/material.dart';
import '../../../../../core/utils/theme.dart';
import '../../domain/entities/item.dart';

class PopularDishCard extends StatelessWidget {
  final Item item;
  final String restaurantName;
  final String priceLabel;
  final VoidCallback? onTap;

  const PopularDishCard({
    super.key,
    required this.item,
    required this.restaurantName,
    required this.priceLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.image != null && item.image!.isNotEmpty
        ? item.image![0]
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: Image.network(
                imageUrl,
                height: 70,
                width: 140,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    restaurantName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        priceLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
