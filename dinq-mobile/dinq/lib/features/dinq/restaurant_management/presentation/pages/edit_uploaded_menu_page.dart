// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import 'edit_menu_item_page.dart';

class EditUploadedMenuPage extends StatefulWidget {
  final File uploadedImage;
  final List<dynamic>? menuItems;

  const EditUploadedMenuPage({super.key, required this.uploadedImage, this.menuItems});

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

  Map<String, List<Map<String, dynamic>>> _processMenuItems(List<dynamic> menuItems) {
    // Group menu items by tab_tags or just put them all in one section
    Map<String, List<Map<String, dynamic>>> sections = {};

    for (var item in menuItems) {
      // Get the first tab tag as the section name, or use 'General' as default
      String sectionName = 'General';
      if (item['tab_tags'] != null && item['tab_tags'] is List && item['tab_tags'].isNotEmpty) {
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
              onPressed: _isExtracting
                  ? null
                  : () {
                      // After publish, redirect to GeneratedQrPage using AppRoute
                      Navigator.of(context).pushNamed(
                        AppRoute.qrcustomization,
                        arguments: {
                          // Replace with actual QR image path after generation
                          'qrImagePath': 'assets/images/qr_placeholder.png',
                        },
                      );
                    },
              child: Row(
                children: const [
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
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
                              section.key == 'General' ? 'Menu Items' : section.key,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            ...section.value
                                .map((item) => _EditableMenuItem(item: item))
                                .toList(),
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
    return words.take(4).join(' ') + '...';
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
                  if (widget.item['allergies'] != null && widget.item['allergies'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Allergies: ${widget.item['allergies']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                  if (widget.item['preparation_time'] != null && widget.item['preparation_time'] > 0) ...[
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
