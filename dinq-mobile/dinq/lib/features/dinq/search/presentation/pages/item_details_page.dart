import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';
import '../../domain/entities/menu.dart' as models;

class ItemDetailsPage extends StatelessWidget {
  final models.Item item;

  const ItemDetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemImage(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${item.price.toStringAsFixed(0)} ${item.currency}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (item.description != null) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (item.ingredients != null && item.ingredients!.isNotEmpty) ...[
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.ingredients!.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (item.allergies != null && item.allergies!.isNotEmpty) ...[
                    const Text(
                      'Allergies',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.allergies!.map((allergy) {
                        return Chip(
                          label: Text(allergy),
                          backgroundColor: Colors.red[100],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (item.calories != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          '${item.calories} calories',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (item.preparationTime != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Preparation time: ${item.preparationTime} minutes',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (item.averageRating != null) ...[
                    Row(
                      children: [
                        const Text(
                          'Rating: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (item.averageRating ?? 0).floor()
                                ? Icons.star
                                : index < (item.averageRating ?? 0)
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${item.averageRating?.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to order functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Add to Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildItemImage() {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          child: item.images != null && item.images!.isNotEmpty
              ? Image.network(
                  item.images![0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  item.averageRating?.toStringAsFixed(1) ?? '4.8',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home_outlined, 'Home', true),
          _buildNavBarItem(Icons.favorite_border, 'Favorites', false),
          _buildNavBarItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? AppColors.primaryColor : Colors.grey,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}