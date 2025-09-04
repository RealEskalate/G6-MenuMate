// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../../core/util/theme.dart';
import '../widgets/owner_navbar.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final totalMenuViews = 1245;
    final totalQrScans = 400;
    final visitorsByHour = [4, 7, 10, 14, 18, 22, 19, 15, 10];
    final visitorLabels = [
      '8AM',
      '10AM',
      '12PM',
      '2PM',
      '4PM',
      '6PM',
      '8PM',
      '10PM', 
    ];
    final popularItems = [
      {'name': 'Special Firfir', 'views': 245},
      {'name': 'Shawarma', 'views': 198},
      {'name': 'Combo', 'views': 156},
      {'name': 'Lasagna', 'views': 142},
      {'name': 'Caprese Salad', 'views': 115},
    ];
    final reviews = [
      {
        'user': 'Alex J.',
        'reviewer': 'Derek Tibs',
        'text': 'Portion could be bigger ...',
        'date': 'Aug 12',
        'rating': 4,
      },
      {
        'user': 'Alex J.',
        'reviewer': 'Derek Tibs',
        'text': 'Portion could be bigger ...',
        'date': 'Aug 12',
        'rating': 4,
      },
      {
        'user': 'Alex J.',
        'reviewer': 'Derek Tibs',
        'text': 'Portion could be bigger ...',
        'date': 'Aug 12',
        'rating': 4,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Analytics',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SizedBox(height: 8),
          Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  icon: Icons.groups,
                  label: 'Total Menu View',
                  value: totalMenuViews.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  icon: Icons.groups,
                  label: 'Total QR Scans',
                  value: totalQrScans.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Visitors by Time of Day',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 15),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.download,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(visitorLabels.length, (i) {
                      final max = visitorsByHour.reduce(
                        (a, b) => a > b ? a : b,
                      );
                      final barHeight = (visitorsByHour[i] / max) * 80;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: barHeight,
                              width: 18,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              visitorLabels[i],
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Popular Menu Items',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 15),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.download,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...popularItems.map((item) {
                  final maxViews = popularItems.first['views'] as int;
                  final percent = (item['views'] as int) / maxViews;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item['name'] as String,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: percent,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item['views']} views',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'All Reviews',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...reviews.map((review) => _ReviewCard(review: review)),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: OwnerNavBar(currentIndex: 0, restaurantId: 'dummy'),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primaryColor.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primaryColor.withOpacity(0.12)),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primaryColor.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['user'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    review['reviewer'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    review['text'],
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      review['rating'].toString(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                  ],
                ),
                Text(
                  review['date'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
