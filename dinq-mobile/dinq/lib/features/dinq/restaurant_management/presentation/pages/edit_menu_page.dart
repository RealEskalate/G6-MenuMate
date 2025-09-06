import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';
import 'edit_single_menu_page.dart';
import 'edit_menu_item_page.dart';
import '../../../../../core/routing/app_route.dart';

class EditMenuPage extends StatelessWidget {
  const EditMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy menu data for demonstration
    final menuSections = [
      {
        'title': 'Main Dishes',
        'groups': [
          {
            'name': 'Breakfast',
            'items': List.generate(3, (_) => _dummyMenuItem),
          },
          {'name': 'Lunch', 'items': List.generate(3, (_) => _dummyMenuItem)},
        ],
      },
      {
        'title': 'Appetizers',
        'groups': [
          {'name': '', 'items': List.generate(2, (_) => _dummyMenuItem)},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit menu',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ...menuSections.map((section) => _MenuSectionCard(section: section)),
        ],
      ),
    );
  }
}

class _MenuSectionCard extends StatelessWidget {
  final Map<String, dynamic> section;
  const _MenuSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.whiteColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  section['title'],
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 17),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.secondaryColor),
                  onPressed: () {
                    // Build a dummy menuData for EditSingleMenuPage
                    final dummyMenuData = {
                      'name': section['title'] ?? '',
                      'language': 'Amharic',
                      'tags': [],
                      'sections': (section['groups'] as List)
                          .map(
                            (group) => {
                              'name': group['name'] ?? '',
                              'items': (group['items'] as List)
                                  .map(
                                    (item) => {
                                      'name': item['name'] ?? '',
                                      'price': item['price'] ?? '',
                                      'desc': item['desc'] ?? '',
                                      'howToEat': '',
                                      'ingredients': [],
                                      'image': item['image'],
                                    },
                                  )
                                  .toList(),
                            },
                          )
                          .toList(),
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditSingleMenuPage(menuData: dummyMenuData),
                      ),
                    );
                  },
                ),
              ],
            ),
            ...section['groups'].map<Widget>((group) {
              final groupName = group['name'] as String;
              final items = group['items'] as List<Map<String, dynamic>>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (groupName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        groupName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: items
                        .map((item) => _MenuItemCard(item: item))
                        .toList(),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        color: AppColors.whiteColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item['image'],
                  height: 70,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['name'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['desc'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'ETB ${item['price']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoute.editMenuItem,
                        arguments: {'item': item},
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy menu item data
const _dummyMenuItem = {
  'image': 'assets/images/doro_wat.jpg',
  'name': 'Doro Wat',
  'desc': 'Spicy chicken stew with berbere sauce, served with injera.',
  'price': '350',
};
