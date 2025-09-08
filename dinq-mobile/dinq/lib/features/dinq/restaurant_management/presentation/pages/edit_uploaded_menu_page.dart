// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../../../core/constants/constants.dart';
import 'edit_menu_item_page.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/restaurant_event.dart';

class EditUploadedMenuPage extends StatefulWidget {
  final File uploadedImage;
  final List<dynamic>? menuItems;

  const EditUploadedMenuPage(
      {super.key, required this.uploadedImage, this.menuItems});

  @override
  State<EditUploadedMenuPage> createState() => _EditUploadedMenuPageState();
}

class _EditUploadedMenuPageState extends State<EditUploadedMenuPage> {
  bool _isExtracting = true;
  late File _currentImage;
  late Map<String, List<Map<String, dynamic>>> _menuSections;

  // Example extracted menu data (replace with real OCR results)
  final Map<String, List<Map<String, dynamic>>> _dummyMenuSections = {
    'Breakfast': [
      {
        'name': 'Sambusa',
        'desc': 'Crispy pastry filled with spiced lentils and vegetables',
        'price': '45',
      },
      {
        'name': 'Timatim Salad',
        'desc': 'Fresh tomato salad with onions and jalapeños',
        'price': '35',
      },
      {
        'name': 'Injera Rolls',
        'desc': 'Traditional sourdough flatbread served warm',
        'price': '25',
      },
      {
        'name': 'Kitfo Appetizer',
        'desc': 'Ethiopian beef tartare with spiced butter and mitmita',
        'price': '85',
      },
    ],
    'Lunch': [
      {
        'name': 'Injera Rolls',
        'desc': 'Traditional sourdough flatbread served warm',
        'price': '25',
      },
      {
        'name': 'Kitfo Appetizer',
        'desc': 'Ethiopian beef tartare with spiced butter and mitmita',
        'price': '85',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _currentImage = widget.uploadedImage;
    if (widget.menuItems != null) {
      _menuSections = _processMenuItems(widget.menuItems!);
      _isExtracting = false;
    } else {
      _menuSections = _dummyMenuSections;
      _simulateExtraction();
    }
  }

  Map<String, List<Map<String, dynamic>>> _processMenuItems(
      List<dynamic> menuItems) {
    // Group menu items by tab_tags or just put them all in one section
    Map<String, List<Map<String, dynamic>>> sections = {};

    for (var item in menuItems) {
      // Get the first tab tag as the section name, or use 'General' as default
      String sectionName = 'General';
      if (item['tab_tags'] != null &&
          item['tab_tags'] is List &&
          item['tab_tags'].isNotEmpty) {
        sectionName = item['tab_tags'][0];
      }

      if (!sections.containsKey(sectionName)) {
        sections[sectionName] = [];
      }

      sections[sectionName]!.add({
        'name': item['name'] ?? '',
        'desc': item['description'] ?? '',
        'price': item['price']?.toString() ?? '0',
        'currency': item['currency'] ?? 'ETB',
        'allergies': item['allergies'] ?? '',
        'preparation_time': item['preparation_time'] ?? 0,
        'nutritional_info': item['nutritional_info'] ?? {},
        'name_am': item['name_am'] ?? '',
        'description_am': item['description_am'] ?? '',
      });
    }

    return sections;
  }

  void _simulateExtraction() {
    setState(() {
      _isExtracting = true;
    });
    // Simulate OCR extraction delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isExtracting = false;
        // Optionally update _menuSections with new dummy data
      });
    });
  }

  void _reScan() {
    Navigator.of(context).pop(); // Go back to DigitizeMenuPage
  }

  Future<void> _publishMenu() async {
    print('🚀 Starting menu publishing process...');
    print('🌐 Using base URL: $baseUrl');

    // Show loading indicator
    setState(() {
      _isExtracting = true;
    });

    final apiClient = ApiClient(baseUrl: baseUrl);

    try {
      // Convert menu sections back to flat menu items list
      List<Map<String, dynamic>> menuItems = [];
      print('📋 Converting menu sections to flat list...');

      _menuSections.forEach((sectionName, items) {
        print('📂 Processing section: $sectionName with ${items.length} items');
        for (var item in items) {
          final menuItem = {
            'name': item['name'] ?? '',
            'name_am': item['name_am'] ?? '',
            'description': item['desc'] ?? '',
            'description_am': item['description_am'] ?? '',
            'tab_tags':
                sectionName == 'Menu Items' ? ['General'] : [sectionName],
            'tab_tags_am':
                sectionName == 'Menu Items' ? ['አጠቃላይ'] : [sectionName],
            'price': int.tryParse(item['price']?.toString() ?? '0') ?? 0,
            'currency': item['currency'] ?? 'ETB',
            'allergies': item['allergies'] ?? '',
            'allergies_am': item['allergies'] ?? '',
            'nutritional_info': item['nutritional_info'] ?? {},
            'preparation_time': item['preparation_time'] ?? 15,
            'how_to_eat': item['how_to_eat'] ?? '',
            'how_to_eat_am': item['how_to_eat_am'] ?? '',
          };
          menuItems.add(menuItem);
          print(
              '📝 Added item: ${menuItem['name']} - ${menuItem['price']} ${menuItem['currency']}');
        }
      });

      print('✅ Converted ${menuItems.length} menu items');

      // Step 1: Create menu
      print('📝 Step 1: Creating menu with ${menuItems.length} items');
      final menuData = {'name': 'OCR Generated Menu', 'menu_items': menuItems};

      print(
          '📤 Sending menu creation request to: $baseUrl/menus/the-italian-corner-4b144298');
      print('📋 Menu data structure: ${menuData.keys}');
      print(
          '🔍 First menu item sample: ${menuItems.isNotEmpty ? menuItems[0] : 'No items'}');

      final createResponse = await apiClient
          .post('/menus/the-italian-corner-4b144298', body: menuData);
      print('📥 Menu creation response: $createResponse');
      print('✅ Menu creation SUCCESS!');

      final menuId = createResponse['data']['menu']['id'];
      final restaurantSlug = 'the-italian-corner-4b144298';

      print('✅ Menu created with ID: $menuId');
      print('🏪 Restaurant slug: $restaurantSlug');

      // Step 2: Publish the menu
      print('📢 Step 2: Publishing menu');
      print('🔗 Publish URL: $baseUrl/menus/$restaurantSlug/publish/$menuId');

      final publishResponse =
          await apiClient.post('/menus/$restaurantSlug/publish/$menuId');
      print('📥 Menu publish response: $publishResponse');
      print('✅ Menu publishing SUCCESS!');

      // Notify RestaurantBloc that the menu was published
      try {
        if (mounted) {
          context.read<RestaurantBloc>().add(
                PublishMenuEvent(
                    restaurantSlug: restaurantSlug, menuId: menuId),
              );
        }
      } catch (e) {
        // non-fatal: ignore if bloc not available
      }

      print('✅ Complete workflow finished successfully!');

      // Navigate to QR customization page
      if (mounted) {
        print('🧭 Navigating to QR customization page...');
        Navigator.of(context).pushNamed(
          AppRoute.qrcustomization,
          arguments: {
            'menuId': menuId,
            'restaurantSlug': restaurantSlug,
          },
        );
      }
    } catch (e) {
      print('❌ DETAILED ERROR in menu publishing process: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e.toString().contains('403')) {
        print('🚫 403 Forbidden Error - Check authentication and permissions');
      } else if (e.toString().contains('404')) {
        print('🔍 404 Not Found Error - Check endpoint URL');
      } else if (e.toString().contains('400')) {
        print('📝 400 Bad Request Error - Check request data format');
      }

      setState(() {
        _isExtracting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu publishing failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Theme.of(context).iconTheme.color),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Upload Menu',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 20),
        ),
        actions: [
          SizedBox(width: 30),
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: _isExtracting ? null : _publishMenu,
              child: _isExtracting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Publishing...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : const Row(
                      children: [
                        Text(
                          'Publish',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
      body: _isExtracting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 18),
                  Text(
                    'Extracting text...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Uploaded image
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'original menu',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _currentImage,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right: Editable menu
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      right: 8,
                      bottom: 8,
                    ),
                    child: ListView(
                      children: _menuSections.entries.map((section) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.key == 'General'
                                  ? 'Menu Items'
                                  : section.key,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            ...section.value
                                .map((item) => _EditableMenuItem(item: item)),
                            const SizedBox(height: 18),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: const Border(
            top: BorderSide(color: Color(0xFFEAEAEA), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomBarButton(icon: Icons.drafts, label: 'Draft', onTap: () {}),
            _BottomBarButton(
              icon: Icons.translate,
              label: 'Translate',
              onTap: () {},
            ),
            _BottomBarButton(
              icon: Icons.qr_code_scanner,
              label: 'Re-scan',
              onTap: _reScan,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableMenuItem extends StatefulWidget {
  final Map<String, dynamic> item;
  const _EditableMenuItem({required this.item});

  @override
  State<_EditableMenuItem> createState() => _EditableMenuItemState();
}

class _EditableMenuItemState extends State<_EditableMenuItem> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name']);
    _descController = TextEditingController(text: widget.item['desc']);
    _priceController = TextEditingController(text: widget.item['price']);
  }

  String _truncateDescription(String desc) {
    final words = desc.split(' ');
    if (words.length <= 4) return desc;
    return '${words.take(4).join(' ')}...';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item['name'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _truncateDescription(widget.item['desc'] ?? ''),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                  ),
                  if (widget.item['allergies'] != null &&
                      widget.item['allergies'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Allergies: ${widget.item['allergies']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: Colors.orange,
                          ),
                    ),
                  ],
                  if (widget.item['preparation_time'] != null &&
                      widget.item['preparation_time'] > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Prep time: ${widget.item['preparation_time']} min',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: Colors.blue,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (widget.item['price'] ?? '').toString(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primaryColor,
                          ),
                    ),
                    Text(
                      widget.item['currency'] ?? 'ETB',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.primaryColor,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EditMenuItemPage(item: widget.item),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomBarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 26),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
