import 'package:flutter/material.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../search/domain/entities/menu.dart' as models;
import '../pages/restaurant_page.dart';

class NearbyRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final Function()? onViewMenu;

  const NearbyRestaurantCard({
    super.key, 
    required this.restaurant,
    this.onViewMenu,
  });

  // Create dummy menu data for restaurant page
  models.Menu _createDummyMenu(String restaurantId) {
    return models.Menu(
      id: 'dummy-menu-id',
      restaurantId: restaurantId,
      branchId: 'dummy-branch-id',
      version: 1,
      isPublished: true,
      tabs: [
        models.Tab(
          id: 'tab1',
          menuId: 'dummy-menu-id',
          name: 'Main Menu',
          categories: [
            models.Category(
              id: 'cat1',
              tabId: 'tab1',
              name: 'Appetizers',
              items: [
                models.Item(
                  id: 'item1',
                  name: 'Samosas',
                  slug: 'samosas',
                  categoryId: 'cat1',
                  description: 'Crispy pastry filled with spiced potatoes and peas.',
                  price: 120.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1601050690597-df0568f70950'],
                  ingredients: ['Flour', 'Potatoes', 'Peas', 'Spices'],
                  preparationTime: 15,
                  calories: 250,
                ),
                models.Item(
                  id: 'item2',
                  name: 'Spring Rolls',
                  slug: 'spring-rolls',
                  categoryId: 'cat1',
                  description: 'Crispy rolls filled with vegetables and served with sweet chili sauce.',
                  price: 100.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1548811256-1627d99e7a57'],
                  ingredients: ['Rice paper', 'Carrots', 'Cabbage', 'Bean sprouts'],
                  preparationTime: 20,
                  calories: 180,
                ),
              ],
            ),
            models.Category(
              id: 'cat2',
              tabId: 'tab1',
              name: 'Main Courses',
              items: [
                models.Item(
                  id: 'item3',
                  name: 'Doro Wat',
                  slug: 'doro-wat',
                  categoryId: 'cat2',
                  description: 'Ethiopian spicy chicken stew served with injera.',
                  price: 250.0,
                  currency: 'ETB',
                  images: ['https://images.unsplash.com/photo-1567364667030-4d45a0a51201'],
                  ingredients: ['Chicken', 'Berbere', 'Onions', 'Garlic', 'Ginger'],
                  preparationTime: 45,
                  calories: 450,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

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
            if (onViewMenu != null) {
              // Use the callback if provided
              onViewMenu!();
            } else {
              // Default navigation with dummy menu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantPage(
                    restaurant: restaurant,
                    menu: _createDummyMenu(restaurant.id),
                  ),
                ),
              );
            }
          },
          child: const Text('View Menu'),
        ),
      ),
    );
  }
}