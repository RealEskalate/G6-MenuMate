import 'package:flutter/material.dart';

import '../../../../../core/util/theme.dart';
import '../widgets/bottom_navbar.dart';
<<<<<<< HEAD
import '../../../search/domain/usecases/get_menu.dart';
import '../../../search/domain/entities/menu.dart' as models;
import 'item_details_page.dart';
=======
import '../widgets/scanned_menu.dart';
>>>>>>> origin/mite-test

class ScannedMenuPage extends StatefulWidget {
  final String slug;
  
  const ScannedMenuPage({super.key, required this.slug});

  @override
  State<ScannedMenuPage> createState() => _ScannedMenuPageState();
}

class _ScannedMenuPageState extends State<ScannedMenuPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Restaurant info
  String _restaurantName = '';
  String _restaurantType = '';
  
  // Menu data
  List<dynamic> _menuSections = [];
  
  final GetMenuUseCase _getMenuUseCase = GetMenuUseCase();
  
  @override
  void initState() {
    super.initState();
    _fetchMenuData();
  }
  
  Future<void> _fetchMenuData() async {
    print('ScannedMenuPage: Fetching menu data for slug: ${widget.slug}');
    try {
      final result = await _getMenuUseCase.execute(widget.slug);
      
      result.fold(
        (failure) {
          print('ScannedMenuPage: Error fetching menu: ${failure.message}');
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = failure.message;
          });
        },
        (menu) {
          print('ScannedMenuPage: Successfully fetched menu data');
          // Process menu data
          _processMenuData(menu);
        },
      );
    } catch (e) {
      print('ScannedMenuPage: Exception fetching menu: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }
  
  void _processMenuData(models.Menu menu) {
    print('ScannedMenuPage: Processing menu data');
    // Extract restaurant info from the first tab if available
    final restaurantId = menu.restaurantId;
    
    // For now, use mock restaurant name and type
    // In a real app, you would fetch this from the restaurant API
    _restaurantName = 'Restaurant $restaurantId';
    _restaurantType = 'Fine Dining';
    
    // Process menu sections from tabs
    final sections = <Map<String, dynamic>>[];
    
    for (final tab in menu.tabs) {
      print('ScannedMenuPage: Processing tab: ${tab.name}');
      
      for (final category in tab.categories) {
        final sectionItems = <Map<String, dynamic>>[];
        
        for (final item in category.items) {
          sectionItems.add({
            'item': item, // Store the original item object for navigation
            'name': item.name,
            'price': '${item.currency}${item.price}',
            'description': item.description ?? 'No description available',
            'imageUrl': item.images?.isNotEmpty == true
                ? item.images!.first
                : 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
          });
        }
        
        if (sectionItems.isNotEmpty) {
          sections.add({
            'name': category.name ?? tab.name,
            'icon': _getIconForCategory(category.name ?? tab.name),
            'items': sectionItems,
          });
        }
      }
    }
    
    setState(() {
      _menuSections = sections;
      _isLoading = false;
    });
  }
  
  IconData _getIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('appetizer') || name.contains('starter')) {
      return Icons.emoji_food_beverage;
    } else if (name.contains('main') || name.contains('entree')) {
      return Icons.local_dining;
    } else if (name.contains('dessert')) {
      return Icons.icecream;
    } else if (name.contains('drink') || name.contains('beverage')) {
      return Icons.local_bar;
    } else if (name.contains('pizza')) {
      return Icons.local_pizza;
    } else {
      return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Menu Preview',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        selectedTab: BottomNavTab.explore,
        onTabSelected: (tab) {
          // Implement navigation if needed
        },
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text('Loading menu...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $_errorMessage', style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _fetchMenuData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Restaurant Info
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.restaurant_menu,
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _restaurantName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  _restaurantType,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
        const SizedBox(height: 18),

        // Menu sections
        if (_menuSections.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No menu items found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          )
        else
          ..._buildMenuSections(),

        const SizedBox(height: 24),
        // Save & Share Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share, color: Colors.white),
            label: const Text(
              'Save & Share Digital Menu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  List<Widget> _buildMenuSections() {
    final widgets = <Widget>[];
    
    for (int i = 0; i < _menuSections.length; i++) {
      final section = _menuSections[i];
      widgets.add(
        _SectionHeader(
          icon: section['icon'],
          label: section['name'],
        ),
      );
      widgets.add(const SizedBox(height: 10));
      
      for (final item in section['items']) {
        widgets.add(
          GestureDetector(
            onTap: () {
              // Navigate to item details page with the original item object
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailsPage(item: item['item']),
                ),
              );
            },
            child: MenuItemCard(
              imageUrl: item['imageUrl'],
              name: item['name'],
              price: item['price'],
              description: item['description'],
            ),
          ),
        );
      }
      
      if (i < _menuSections.length - 1) {
        widgets.add(const SizedBox(height: 18));
      }
    }
    
    return widgets;
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 22),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
