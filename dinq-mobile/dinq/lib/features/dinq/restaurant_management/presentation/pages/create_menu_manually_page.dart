// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../../core/util/theme.dart';
import '../widgets/upload_image.dart';

class CreateMenuManuallyPage extends StatefulWidget {
  final String restaurantId;
  const CreateMenuManuallyPage({super.key, required this.restaurantId});

  @override
  State<CreateMenuManuallyPage> createState() => _CreateMenuManuallyPageState();
}

class _CreateMenuManuallyPageState extends State<CreateMenuManuallyPage> {
  Future<void> _pickVoice(int sectionIndex, int itemIndex) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _sections[sectionIndex].items[itemIndex].voiceFile = File(
          result.files.single.path!,
        );
      });
    }
  }

  void _removeVoice(int sectionIndex, int itemIndex) {
    setState(() {
      _sections[sectionIndex].items[itemIndex].voiceFile = null;
    });
  }

  List<bool> _sectionExpanded = [];

  @override
  void initState() {
    super.initState();
    _sectionExpanded = List<bool>.filled(
      _sections.length,
      false,
      growable: true,
    );
  }

  @override
  void dispose() {
    _menuNameController.dispose();
    for (final section in _sections) {
      section.dispose();
    }
    super.dispose();
  }

  final TextEditingController _menuNameController = TextEditingController();
  String _selectedLanguage = 'Amharic';
  final List<String> _tags = [];
  final List<_SectionData> _sections = [_SectionData()];

  void _addTag(String tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  void _addSection() {
    setState(() {
      _sections.add(_SectionData());
      _sectionExpanded.add(false); // keep in sync with sections
    });
  }

  void _addItem(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].items.add(_ItemData());
    });
  }

  void _addIngredient(int sectionIndex, int itemIndex, String ingredient) {
    setState(() {
      _sections[sectionIndex].items[itemIndex].ingredients.add(ingredient);
    });
  }

  Future<void> _pickImage(int sectionIndex, int itemIndex) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _sections[sectionIndex].items[itemIndex].imageFile = File(
          pickedFile.path,
        );
      });
    }
  }

  // Add this method to handle image removal and prompt for re-upload
  void _removeImage(int sectionIndex, int itemIndex) async {
    setState(() {
      _sections[sectionIndex].items[itemIndex].imageFile = null;
    });
    // Also remove expansion state if section is removed
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Removed'),
        content: const Text(
          'You have removed the food image. Would you like to upload a new one now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
    if (shouldUpload == true) {
      _pickImage(sectionIndex, itemIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Theme.of(context).iconTheme.color),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Create menu manually',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Basic Details Card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _menuNameController,
                    decoration: InputDecoration(
                      labelText: 'Menu name',
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText: 'untitled menu',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: 'Language',
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Amharic',
                        child: Text('Amharic'),
                      ),
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: [
                      ..._tags.map((tag) => Chip(label: Text(tag))),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Add tags'),
                        onPressed: () async {
                          // Simple tag input dialog
                          final tag = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController();
                              return AlertDialog(
                                title: const Text('Add Tag'),
                                content: TextField(
                                  controller: controller,
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, controller.text),
                                    child: const Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (tag != null && tag.trim().isNotEmpty)
                            _addTag(tag.trim());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Sections
          ..._sections.asMap().entries.map((sectionEntry) {
            final sectionIndex = sectionEntry.key;
            final section = sectionEntry.value;
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _sectionExpanded.length > sectionIndex &&
                                    _sectionExpanded[sectionIndex]
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _sectionExpanded[sectionIndex] =
                                  !_sectionExpanded[sectionIndex];
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: section.selectedSectionTag,
                            decoration: InputDecoration(
                              labelText: 'Section',
                              labelStyle: const TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Breakfast',
                                child: Text('Breakfast'),
                              ),
                              DropdownMenuItem(
                                value: 'Lunch',
                                child: Text('Lunch'),
                              ),
                              DropdownMenuItem(
                                value: 'Dinner',
                                child: Text('Dinner'),
                              ),
                              DropdownMenuItem(
                                value: 'Drinks',
                                child: Text('Drinks'),
                              ),
                              DropdownMenuItem(
                                value: 'Desserts',
                                child: Text('Desserts'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  section.selectedSectionTag = val;
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: _sections.length > 1
                              ? () => setState(
                                  () => _sections.removeAt(sectionIndex),
                                )
                              : null,
                        ),
                      ],
                    ),
                    if (_sectionExpanded.length > sectionIndex &&
                        _sectionExpanded[sectionIndex]) ...[
                      const SizedBox(height: 14),
                      ...section.items.asMap().entries.map((itemEntry) {
                        final itemIndex = itemEntry.key;
                        final item = itemEntry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: item.nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Item ${itemIndex + 1}',
                                      labelStyle: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: item.priceController,
                                    decoration: InputDecoration(
                                      labelText: 'ETB',
                                      labelStyle: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    icon: const Icon(Icons.image_search),
                                    label: const Text(
                                      'Extract from menu photo',
                                    ),
                                    onPressed: () {
                                      // TODO: Implement extract from menu photo logic
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Choose from gallery'),
                                    onPressed: () =>
                                        _pickImage(sectionIndex, itemIndex),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 6),
                                const Text(
                                  'Add ingredient',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppColors.primaryColor,
                                  ),
                                  tooltip: 'Add ingredient',
                                  onPressed: () async {
                                    final ingredient = await showDialog<String>(
                                      context: context,
                                      builder: (context) {
                                        final controller =
                                            TextEditingController();
                                        return AlertDialog(
                                          title: const Text('Add Ingredient'),
                                          content: TextField(
                                            controller: controller,
                                            autofocus: true,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                context,
                                                controller.text,
                                              ),
                                              child: const Text('Add'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (ingredient != null &&
                                        ingredient.trim().isNotEmpty) {
                                      _addIngredient(
                                        sectionIndex,
                                        itemIndex,
                                        ingredient.trim(),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    children: item.ingredients
                                        .map(
                                          (ingredient) =>
                                              Chip(label: Text(ingredient)),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: item.descController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: item.howToEatController,
                              decoration: InputDecoration(
                                labelText: 'How to eat',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                hintText: 'Instructions (max 100 chars)',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              maxLength: 100,
                            ),
                            const SizedBox(height: 10),
                            // Voice upload field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Voice Instruction (mp3)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (item.voiceFile == null)
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.upload_file,
                                            color: AppColors.primaryColor,
                                          ),
                                          label: const Text(
                                            'Upload mp3 (max 10MB)',
                                            style: TextStyle(
                                              color: AppColors.secondaryColor,
                                            ),
                                          ),
                                          onPressed: () => _pickVoice(
                                            sectionIndex,
                                            itemIndex,
                                          ),
                                        )
                                      else ...[
                                        Expanded(
                                          child: Text(
                                            item.voiceFile!.path
                                                .split(Platform.pathSeparator)
                                                .last,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _removeVoice(
                                            sectionIndex,
                                            itemIndex,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryColor,
                              side: BorderSide(color: AppColors.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Add section'),
                            onPressed: _addSection,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryColor,
                              side: BorderSide(color: AppColors.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Add item'),
                            onPressed: () => _addItem(sectionIndex),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // TODO: Implement publish menu logic
                // Use widget.restaurantId when sending menu data to backend
                // Example: sendMenuToBackend(widget.restaurantId, menuData);
              },
              child: const Text(
                'Publish Menu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Section and Item data models for form state
class _SectionData {
  String selectedSectionTag;
  final List<_ItemData> items = [_ItemData()];

  _SectionData({this.selectedSectionTag = 'Breakfast'});

  void dispose() {
    for (final item in items) {
      item.dispose();
    }
  }
}

class _ItemData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController howToEatController = TextEditingController();
  final List<String> ingredients = [];
  File? imageFile;
  File? voiceFile;

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    howToEatController.dispose();
  }
}
