import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🖼 LEFT IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildImage(),
              ),

              const SizedBox(width: 14),

              /// 📄 RIGHT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Item Name
                    Text(
                      item.name,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.secondaryColor,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Description
                    if (item.description != null &&
                        item.description!.isNotEmpty)
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),

                    const SizedBox(height: 10),

                    /// Price
                    Text(
                      '${item.price} ${item.currency}',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.image != null &&
        item.image!.isNotEmpty &&
        item.image!.first.isNotEmpty) {
      return Image.network(
        item.image!.first,
        width: 95,
        height: 95,
        fit: BoxFit.cover,
      );
    }

    /// Fallback
    return Container(
      width: 95,
      height: 95,
      color: AppColors.secondaryColor.withOpacity(0.1),
      child: const Icon(
        Icons.fastfood,
        color: AppColors.secondaryColor,
      ),
    );
  }
}
