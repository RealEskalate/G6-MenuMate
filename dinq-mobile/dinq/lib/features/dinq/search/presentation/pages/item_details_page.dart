import 'package:dinq/features/dinq/search/presentation/pages/add_review_page.dart';
import 'package:dinq/features/dinq/search/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../domain/entities/menu.dart' as models;

// Add this at the top of item_details_page.dart or in a shared file
class _FavoritesStore {
  static final Set<String> restaurantIds = <String>{};
  static final Set<String> dishIds = <String>{};
}

class ItemDetailsPage extends StatefulWidget {
  final models.Item item;

  const ItemDetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  static final Set<String> _favoriteDishIds = {}; // For UI only

  bool get isFavorite => _favoriteDishIds.contains(widget.item.id);

  void _toggleFavorite() {
  setState(() {
    if (_FavoritesStore.dishIds.contains(widget.item.id)) {
      _FavoritesStore.dishIds.remove(widget.item.id);
    } else {
      _FavoritesStore.dishIds.add(widget.item.id);
    }
  });
}

  void _onTabSelected(BottomNavTab tab) {
    if (tab == BottomNavTab.explore) {
      Navigator.pushReplacementNamed(context, AppRoute.explore);
    } else if (tab == BottomNavTab.favorites) {
      Navigator.pushReplacementNamed(context, AppRoute.favorites);
    } else if (tab == BottomNavTab.profile) {
      Navigator.pushReplacementNamed(context, AppRoute.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Text(widget.item.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.item.price.toStringAsFixed(0)} ${widget.item.currency}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(
                      Icons.translate_rounded,
                      color: Colors.black,
                    ),
                    onPressed: () {},
                    label: const Text(
                      'Translate',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 8),
                  if (widget.item.description != null) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.item.ingredients != null &&
                      widget.item.ingredients!.isNotEmpty) ...[
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
                      children: widget.item.ingredients!
                          .map(
                            (ingredient) => Chip(
                              label: Text(ingredient),
                              backgroundColor: Colors.grey[200],
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.item.allergies != null &&
                      widget.item.allergies!.isNotEmpty) ...[
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
                      children: widget.item.allergies!
                          .map(
                            (allergy) => Chip(
                              label: Text(allergy),
                              backgroundColor: Colors.red[100],
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.item.calories != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.item.calories} calories',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  if (widget.item.calories != null) const SizedBox(height: 8),
                  if (widget.item.preparationTime != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Preparation time: ${widget.item.preparationTime} minutes',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  if (widget.item.preparationTime != null)
                    const SizedBox(height: 16),
                  if (widget.item.averageRating != null)
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
                          final rating = widget.item.averageRating ?? 0;
                          return Icon(
                            index < rating.floor()
                                ? Icons.star
                                : index < rating
                                ? Icons.star_half
                                : Icons.star_border,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.item.averageRating?.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // How to eat
                  const Text(
                    'How to eat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lorem ipsum dolor sit amet consectetur. Phasellus faucibus nisi amet enim felis odio cras viverra massa.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  // Chef's Tip
                  const Text(
                    "Chef's Tip",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: const Text(
                            '|||||||||',
                            style: TextStyle(fontSize: 18, letterSpacing: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews (24)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Navigate to Add Review Page
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddReviewPage(),
                            ),
                          );
                        },
                        child: const Text('Add Review'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Review summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Based on 24 reviews',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Individual reviews (static for UI)
                  _buildReviewTile(
                    name: 'Sarah M.',
                    date: '2 days ago',
                    rating: 5,
                    review:
                        "Absolutely amazing! The flavors are authentic and the spice level is perfect. Best Ethiopian food I've had in the city.",
                    images: [
                      'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                      'https://i.pinimg.com/1200x/3d/51/bd/3d51bd3ba5e62f842558c025198a8d5d.jpg',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildReviewTile(
                    name: 'Michael R.',
                    date: '1 week ago',
                    rating: 4,
                    review:
                        "Great dish with rich flavors. The chicken was tender and the sauce was delicious. Portion size is generous too!",
                  ),
                  const SizedBox(height: 12),
                  _buildReviewTile(
                    name: 'Aisha K.',
                    date: '2 weeks ago',
                    rating: 5,
                    review:
                        "This brings back memories of home! Perfectly seasoned and cooked to perfection. Highly recommend!",
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Load More Reviews',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedTab: BottomNavTab.explore,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildItemImage() {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          color: Colors.grey[300],
          child: widget.item.images != null && widget.item.images!.isNotEmpty
              ? Image.network(
                  widget.item.images![0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
                  ),
                )
              : const Center(
                  child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
                ),
        ),
        if (widget.item.averageRating != null)
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
                    widget.item.averageRating!.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewTile({
    required String name,
    required String date,
    required int rating,
    required String review,
    List<String>? images,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(review, style: const TextStyle(fontSize: 15)),
          if (images != null && images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: images
                  .map(
                    (img) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          img,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
