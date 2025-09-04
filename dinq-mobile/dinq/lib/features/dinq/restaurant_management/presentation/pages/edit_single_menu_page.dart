// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/util/theme.dart';
import '../widgets/upload_image.dart';

class EditSingleMenuPage extends StatefulWidget {
  final Map<String, dynamic> menuData; // Pass the menu data to edit

  const EditSingleMenuPage({super.key, required this.menuData});

  @override
  State<EditSingleMenuPage> createState() => _EditSingleMenuPageState();
}

class _EditSingleMenuPageState extends State<EditSingleMenuPage> {
  late List<bool> _sectionExpanded;
  late TextEditingController _menuNameController;
  late String _selectedLanguage;
  late List<String> _tags;
  late List<_SectionEditData> _sections;
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

  @override
  void initState() {
    super.initState();
    _menuNameController = TextEditingController(
      text: widget.menuData['name'] ?? '',
    );
    _selectedLanguage = widget.menuData['language'] ?? 'Amharic';
    _tags = List<String>.from(widget.menuData['tags'] ?? []);
    _sections = (widget.menuData['sections'] as List).map((section) {
      return _SectionEditData.fromMap(section);
    }).toList();
    _sectionExpanded = List<bool>.filled(_sections.length, false);
  }

  void _addTag(String tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
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

  void _removeImage(int sectionIndex, int itemIndex) async {
    setState(() {
      _sections[sectionIndex].items[itemIndex].imageFile = null;
    });
    // Prompt to upload again
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
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.secondaryColor),
        backgroundColor: AppColors.whiteColor,
        foregroundColor: AppColors.secondaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.secondaryColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Basic Details Card
          Card(
            color: AppColors.whiteColor,
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
                  const Text(
                    'Basic Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _menuNameController,
                    decoration: InputDecoration(
                      labelText: 'Menu name',
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
                      ..._tags.map(
                        (tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.primaryColor,
                        ),
                        label: const Text('Add tags'),
                        onPressed: () async {
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
              color: AppColors.whiteColor,
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
                      ],
                    ),
                    if (_sectionExpanded[sectionIndex]) ...[
                      const SizedBox(height: 14),
                      ...section.items.asMap().entries.map((itemEntry) {
                        final itemIndex = itemEntry.key;
                        final item = itemEntry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: item.nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Item ${itemIndex + 1}',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: item.priceController,
                                  decoration: InputDecoration(
                                    labelText: 'ETB',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 10),
                                UploadImage(
                                  imageFile: item.imageFile,
                                  imagePath: item.imagePath,
                                  onPickImage: () =>
                                      _pickImage(sectionIndex, itemIndex),
                                  onDeleteImage: () =>
                                      _removeImage(sectionIndex, itemIndex),
                                  onExtractFromMenuPhoto: () {},
                                ),
                                const SizedBox(height: 10),
                                // Voice upload UI
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Voice Explanation',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                  color:
                                                      AppColors.secondaryColor,
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
                                                    .split(
                                                      Platform.pathSeparator,
                                                    )
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
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              children: item.ingredients
                                  .map(
                                    (ingredient) => Chip(
                                      label: Text(ingredient),
                                      onDeleted: () {
                                        setState(() {
                                          item.ingredients.remove(ingredient);
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
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
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.secondaryColor,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                context,
                                                controller.text,
                                              ),
                                              child: const Text(
                                                'Add',
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
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
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: item.descController,
                              decoration: InputDecoration(
                                labelText: 'Description',
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
                                hintText: 'Instructions (max 100 chars)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              maxLength: 100,
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Voice Explanation',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Upload mp3 (up to 10MB)',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
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
                // TODO: Implement save/update menu logic
              },
              child: const Text(
                'Save Changes',
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

// Section and Item data models for edit form state
class _SectionEditData {
  String selectedSectionTag;
  final List<_ItemEditData> items;

  _SectionEditData({required this.selectedSectionTag, required this.items});

  factory _SectionEditData.fromMap(Map<String, dynamic> map) {
    return _SectionEditData(
      selectedSectionTag: map['name'] ?? 'Breakfast',
      items: (map['items'] as List)
          .map((item) => _ItemEditData.fromMap(item))
          .toList(),
    );
  }
}

class _ItemEditData {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController descController;
  final TextEditingController howToEatController;
  final List<String> ingredients;
  final String? imagePath;
  File? imageFile;
  File? voiceFile;

  _ItemEditData({
    required this.nameController,
    required this.priceController,
    required this.descController,
    required this.howToEatController,
    required this.ingredients,
    this.imagePath,
    this.imageFile,
  });

  factory _ItemEditData.fromMap(Map<String, dynamic> map) {
    return _ItemEditData(
      nameController: TextEditingController(text: map['name'] ?? ''),
      priceController: TextEditingController(
        text: map['price']?.toString() ?? '',
      ),
      descController: TextEditingController(text: map['desc'] ?? ''),
      howToEatController: TextEditingController(text: map['howToEat'] ?? ''),
      ingredients: List<String>.from(map['ingredients'] ?? []),
      imagePath: map['image'],
      imageFile: null,
    );
  }
}
