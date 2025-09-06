import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/data/model/restaurant_model.dart';
import '../widgets/nearby_restaurant_card.dart';

class SearchResultsPopup extends StatelessWidget {
  final List<RestaurantModel> restaurants;
  final bool isLoading;
  final String searchQuery;
  final VoidCallback onClose;
  final Function(RestaurantModel) onRestaurantTap;

  const SearchResultsPopup({
    super.key,
    required this.restaurants,
    required this.isLoading,
    required this.searchQuery,
    required this.onClose,
    required this.onRestaurantTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Search Results for "$searchQuery"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),
                    )
                  : restaurants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No restaurants found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with a different name',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: NearbyRestaurantCard(
                                imageUrl: restaurant.logoImage ?? '',
                                name: restaurant.restaurantName,
                                cuisine: restaurant.tags?.join(', ') ?? 'Restaurant',
                                distance: 'Search result',
                                rating: restaurant.averageRating,
                                reviews: 0, // We don't have review count in the model
                                onViewMenu: () => onRestaurantTap(restaurant),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}