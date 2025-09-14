import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/item.dart';
import '../../../restaurant_management/presentation/bloc/review_bloc.dart';
import '../../../restaurant_management/presentation/bloc/review_event.dart';
import '../../../restaurant_management/presentation/bloc/review_state.dart';
import 'add_review_page.dart';

class ItemDetailsPage extends StatelessWidget {
  final Item item;

  const ItemDetailsPage({super.key, required this.item});

  void _loadReviews(BuildContext context) {
    context.read<ReviewBloc>().add(LoadReviewsEvent(item.id));
  }

  // No local tab navigation or favorites toggling here; keep page stateless.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemImage(),
            const SizedBox(height: 16),
            Text(
              item.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (item.description != null) Text(item.description!),
            const SizedBox(height: 12),

            if (item.allergies != null && item.allergies!.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.allergies!
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

            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.nutritionalInfo?.calories ?? '-'} calories',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.preparationTime != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Preparation time: ${item.preparationTime} minutes',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

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
                  final rating = item.averageRating;
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
                  '${item.averageRating}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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

            const Text(
              "Chef's Tip",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.mic, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '|||||||||',
                      style: TextStyle(fontSize: 18, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reviews Section header (tap title to load reviews)
            InkWell(
              onTap: () => _loadReviews(context),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reviews',
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
              ),
            ),
            const SizedBox(height: 12),

            // Reviews driven by ReviewBloc
            BlocBuilder<ReviewBloc, ReviewState>(
              builder: (context, state) {
                if (state is ReviewLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ReviewsLoaded) {
                  final reviews = state.reviews;
                  if (reviews.isEmpty) return const Text('No reviews yet');
                  return Column(
                    children: reviews.map((r) {
                      return Column(
                        children: [
                          _buildReviewTile(
                            name: r.user.firstName,
                            date: r.createdAt.toString(),
                            rating: r.rating.round(),
                            review: r.comment,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  );
                }

                // initial state - prompt user to tap Reviews header to load
                return const Center(
                    child: Text('Tap "Reviews" above to load reviews'));
              },
            ),

            const SizedBox(height: 16),
            // fallback static sample reviews
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
                  'Great dish with rich flavors. The chicken was tender and the sauce was delicious. Portion size is generous too!',
            ),
            const SizedBox(height: 12),
            _buildReviewTile(
              name: 'Aisha K.',
              date: '2 weeks ago',
              rating: 5,
              review:
                  'This brings back memories of home! Perfectly seasoned and cooked to perfection. Highly recommend!',
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
    );
  }

  Widget _buildItemImage() {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          color: Colors.grey[300],
          child: item.images != null && item.images!.isNotEmpty
              ? Image.network(
                  item.images![0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
                  ),
                )
              : const Center(
                  child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
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
                  item.averageRating.toStringAsFixed(1),
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
                  name.isNotEmpty ? name[0] : '?',
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
