import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/restaurant_event.dart';
import '../bloc/restaurant_state.dart';

class RestaurantMenuPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantMenuPage({super.key, required this.restaurantId});

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Load menu when page opens
    context.read<RestaurantBloc>().add(LoadMenu(widget.restaurantId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menu')),
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RestaurantError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RestaurantBloc>().add(
                        LoadMenu(widget.restaurantId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MenuLoaded) {
            _tabController = TabController(
              length: state.menu.tabs.length,
              vsync: this,
            );

            return Column(
              children: [
                // Restaurant Header
                RestaurantHeader(menu: state.menu),

                // Tabs
                TabBar(
                  controller: _tabController,
                  tabs: state.menu.tabs
                      .map((tab) => Tab(text: tab.name))
                      .toList(),
                  onTap: (index) {
                    final tabId = state.menu.tabs[index].id;
                    // Load category when tab is tapped
                    if (!state.categories.containsKey(tabId)) {
                      context.read<RestaurantBloc>().add(LoadCategories(tabId));
                    }
                  },
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: state.menu.tabs.map((tab) {
                      final categoryResponse = state.categories[tab.id];
                      if (categoryResponse != null) {
                        return CategoryList(
                          categories: categoryResponse as List<Category>,
                          onItemTap: (item) {
                            // LoadItemDetails is not available, just show item details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected: ${item.name}')),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('Tap to load categories'),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}

class RestaurantHeader extends StatelessWidget {
  final Menu menu;

  const RestaurantHeader({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Menu', // Since restaurant name is not available in Menu entity
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text('Menu ID: ${menu.id}'),
          const SizedBox(height: 4),
          Text('Restaurant ID: ${menu.restaurantId}'),
          const SizedBox(height: 4),
          Text('Published: ${menu.isPublished ? 'Yes' : 'No'}'),
          const SizedBox(height: 4),
          Text('View Count: ${menu.viewCount}'),
          const SizedBox(height: 4),
          Text('Tabs: ${menu.tabs.length}'),
        ],
      ),
    );
  }
}

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Function(Item) onItemTap;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...category.items.map(
              (item) => ItemCard(item: item, onTap: () => onItemTap(item)),
            ),
          ],
        );
      },
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: item.image != null
            ? Image.network(
                item.image![0],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.restaurant),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description ?? ''),
            Text('${item.currency} ${item.price}'),
            if (item.averageRating > 0) ...[
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  Text('${item.averageRating}'),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.restaurant_menu),
        onTap: onTap,
      ),
    );
  }
}
