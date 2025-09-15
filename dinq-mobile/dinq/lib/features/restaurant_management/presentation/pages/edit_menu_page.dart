import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../../data/model/menu_create_model.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';

class EditMenuPage extends StatefulWidget {
  const EditMenuPage({super.key});

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  late TextEditingController _menuNameController;
  late TextEditingController _menuDescriptionController;
  MenuCreateModel? _parsedMenuData;
  List<Map<String, dynamic>> _menuItems = [];
  String? _restaurantId;

  @override
  void initState() {
    super.initState();
    _menuNameController = TextEditingController();
    _menuDescriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments from route
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _restaurantId = args['restaurantId'] as String?;
      _parsedMenuData = args['parsedMenuData'] as MenuCreateModel?;
      if (_parsedMenuData != null) {
        _menuNameController.text = _parsedMenuData!.name ?? 'Scanned Menu';
        _menuDescriptionController.text = _parsedMenuData!.description ?? '';
        _menuItems = (_parsedMenuData!.menuItems ?? []).map((item) {
          return {
            'name': item.name ?? '',
            'description': item.description ?? '',
            'price': item.price ?? 0.0,
          };
        }).toList();
      }
    }
  }

  @override
  void dispose() {
    _menuNameController.dispose();
    _menuDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MenuBloc, MenuState>(
      listener: (context, state) {
        if (state is MenuActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context); // Go back to menus page
        } else if (state is MenuError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Edit menu',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actions: [
            TextButton(
              onPressed: _saveMenu,
              child: Text(
                'Save',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menu Name
              TextField(
                controller: _menuNameController,
                decoration: const InputDecoration(
                  labelText: 'Menu Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Menu Description
              TextField(
                controller: _menuDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Menu Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Menu Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: _addMenuItem,
                    icon: Icon(Icons.add, color: AppColors.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _menuItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: AppColors.primaryColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No menu items yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first menu item',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          return _buildMenuItemCard(index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(int index) {
    final item = _menuItems[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: item['name']),
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => _menuItems[index]['name'] = value,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeMenuItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            TextField(
              controller: TextEditingController(text: item['description']),
              decoration: const InputDecoration(
                labelText: 'Description',
                border: InputBorder.none,
              ),
              maxLines: 2,
              onChanged: (value) => _menuItems[index]['description'] = value,
            ),
            TextField(
              controller: TextEditingController(text: item['price'].toString()),
              decoration: const InputDecoration(
                labelText: 'Price',
                border: InputBorder.none,
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _menuItems[index]['price'] = double.tryParse(value) ?? 0.0,
            ),
          ],
        ),
      ),
    );
  }

  void _addMenuItem() {
    setState(() {
      _menuItems.add({
        'name': '',
        'description': '',
        'price': 0.0,
      });
    });
  }

  void _removeMenuItem(int index) {
    setState(() {
      _menuItems.removeAt(index);
    });
  }

  void _saveMenu() {
    if (_menuNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a menu name')),
      );
      return;
    }

    if (_restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant ID not found')),
      );
      return;
    }

    // Create Item objects from menu items
    final items = _menuItems.map((item) {
      return Item(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            item['name'], // Temporary ID
        name: item['name'],
        nameAm: item['name'], // Same as name for now
        slug: item['name'].toLowerCase().replaceAll(' ', '-'),
        menuSlug: '', // Will be set when menu is created
        description: item['description'],
        descriptionAm: item['description'],
        price: item['price'],
        currency: 'ETB',
        viewCount: 0,
        averageRating: 0.0,
        reviewIds: [],
      );
    }).toList();

    // Create Menu object
    final menu = Menu(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      restaurantId: _restaurantId!,
      name: _menuNameController.text,
      description: _menuDescriptionController.text,
      isPublished: false, // Start as unpublished
      items: items,
      viewCount: 0,
    );

    // Dispatch create menu event
    context.read<MenuBloc>().add(CreateMenuEvent(menu));

    // Show loading and listen for result
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating menu...')),
    );
  }
}
