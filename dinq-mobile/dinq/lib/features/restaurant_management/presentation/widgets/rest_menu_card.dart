import 'package:flutter/material.dart';
// import '../../../../restaurant_management/domain/entities/tab.dart' as entity;
import '../../../../../core/util/theme.dart';
// import '../../../../restaurant_management/domain/entities/item.dart';
import '../../domain/entities/item.dart';
import '../pages/edit_menu_page.dart';
// ...existing code... (edit_single_menu_page unused)

class RestMenuCard extends StatelessWidget {
  final dynamic tab; // can be legacy Tab object or a single Item
  final bool isPublished;

  const RestMenuCard({super.key, required this.tab, required this.isPublished});

  List<Item> _getAllItems() {
    // If this is a single Item, return it. Otherwise, try to aggregate
    final items = <Item>[];
    if (tab is Item) {
      items.add(tab as Item);
      return items;
    }

    // Legacy tab shape: aggregate categories -> items
    try {
      for (final category in tab.categories) {
        if (category.items != null) {
          items.addAll(category.items as List<Item>);
        }
      }
    } catch (_) {
      // If the shape is unexpected, return empty list
    }
    return items;
  }

  double? _getAverageRating(List<Item> items) {
    if (items.isEmpty) return null;
    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.averageRating,
    );
    return total / items.length;
  }

  @override
  Widget build(BuildContext context) {
    final items = _getAllItems();
    final avgRating = _getAverageRating(items);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tab is Item ? tab.name : tab.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.secondaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Delete Menu'),
                      content: const Text(
                        'Are you sure you want to delete this menu? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    // TODO: Call delete logic here
                    // Example: context.read<RestaurantBloc>().add(DeleteMenu(tab.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menu deleted successfully'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPublished
                      ? AppColors.primaryColor.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPublished ? Icons.check_circle : Icons.hourglass_empty,
                      color: isPublished ? AppColors.primaryColor : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPublished ? 'Published' : 'Pending',
                      style: TextStyle(
                        color:
                            isPublished ? AppColors.primaryColor : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Menu info and QR
          Row(
            children: [
              // Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoChip(
                    icon: Icons.circle,
                    label: 'Items',
                    value: '${items.length} dishes',
                  ),
                  const SizedBox(height: 8),
                  _InfoChip(
                    icon: Icons.circle,
                    label: 'Avg. rating',
                    value:
                        avgRating != null ? avgRating.toStringAsFixed(1) : '-',
                  ),
                ],
              ),
              const Spacer(),
              // QR code
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code,
                    size: 32,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Actions
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Menu'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditMenuPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
