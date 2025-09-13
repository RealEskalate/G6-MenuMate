import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/util/theme.dart';
import '../../data/model/menu_create_model.dart';

// Enum for menu languages
enum MenuLanguage { amharic, english }

extension MenuLanguageExt on MenuLanguage {
  String get displayName {
    switch (this) {
      case MenuLanguage.amharic:
        return 'Amharic';
      case MenuLanguage.english:
        return 'English';
    }
  }

  static MenuLanguage fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'english':
        return MenuLanguage.english;
      case 'amharic':
      default:
        return MenuLanguage.amharic;
    }
  }
}

class CreateMenuManuallyPage extends StatefulWidget {
  final String restaurantId;
  final MenuCreateModel? parsedMenuData;

  const CreateMenuManuallyPage({
    super.key,
    required this.restaurantId,
    this.parsedMenuData,
  });

  @override
  State<CreateMenuManuallyPage> createState() => _CreateMenuManuallyPageState();
}

class _CreateMenuManuallyPageState extends State<CreateMenuManuallyPage> {
  final TextEditingController _menuNameController = TextEditingController();
  MenuLanguage _selectedLanguage = MenuLanguage.amharic; // default
  final List<String> _tags = [];
  final List<_SectionData> _sections = [_SectionData()];
  final List<bool> _sectionExpanded = [];

  @override
  void initState() {
    super.initState();
    _sectionExpanded.addAll(List<bool>.filled(_sections.length, false));

    // Initialize with parsed menu data if available
    if (widget.parsedMenuData != null) {
      _menuNameController.text = widget.parsedMenuData!.name ?? '';

      // Initialize sections and items from parsed data
      if (widget.parsedMenuData!.menuItems != null &&
          widget.parsedMenuData!.menuItems!.isNotEmpty) {
        _sections.clear();
        _sectionExpanded.clear();

        final section = _SectionData();
        section.selectedSectionTag = 'Main Menu';

        for (final item in widget.parsedMenuData!.menuItems!) {
          final itemData = _ItemData();
          itemData.nameController.text = item.name ?? '';
          itemData.descController.text = item.description ?? '';
          itemData.priceController.text = item.price?.toString() ?? '';
          section.items.add(itemData);
        }

        _sections.add(section);
        _sectionExpanded.add(false);
      }
    }
  }

  @override
  void dispose() {
    _menuNameController.dispose();
    for (final section in _sections) {
      section.dispose();
    }
    super.dispose();
  }

  void _addTag(String tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  void _addSection() {
    setState(() {
      _sections.add(_SectionData());
      _sectionExpanded.add(false);
    });
  }

  void _addItem(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].items.add(_ItemData());
    });
  }

  Future<void> _pickImage(int sectionIndex, int itemIndex) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _sections[sectionIndex].items[itemIndex].imageFile =
            File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVoice(int sectionIndex, int itemIndex) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _sections[sectionIndex].items[itemIndex].voiceFile =
            File(result.files.single.path!);
      });
    }
  }

  void _removeImage(int sectionIndex, int itemIndex) {
    setState(() {
      _sections[sectionIndex].items[itemIndex].imageFile = null;
    });
  }

  void _removeVoice(int sectionIndex, int itemIndex) {
    setState(() {
      _sections[sectionIndex].items[itemIndex].voiceFile = null;
    });
  }

  Future<void> _showAddTagDialog() async {
    final tag = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Tag'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Add')),
          ],
        );
      },
    );

    if (tag != null && tag.trim().isNotEmpty) _addTag(tag.trim());
  }

  Future<void> _showAddIngredientDialog(int sectionIndex, int itemIndex) async {
    final ing = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Ingredient'),
          content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Ingredient')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Add')),
          ],
        );
      },
    );
    if (ing != null && ing.trim().isNotEmpty) {
      setState(() {
        _sections[sectionIndex].items[itemIndex].ingredients.add(ing.trim());
      });
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
        title: const Text('Create menu manually',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Card(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Basic Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _menuNameController,
                      decoration: InputDecoration(
                        hintText: 'untitled menu',
                        hintStyle: const TextStyle(color: Colors.black54),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.primaryColor, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<MenuLanguage>(
                      value: _selectedLanguage,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      items: MenuLanguage.values.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLanguage = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Wrap(spacing: 8, children: [
                      ..._tags.map((tag) => Chip(label: Text(tag))),
                      ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: const Text('Add tags'),
                          onPressed: _showAddTagDialog),
                    ])
                  ]),
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
                      width: 1)),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        IconButton(
                          icon: Icon(
                              _sectionExpanded.length > sectionIndex &&
                                      _sectionExpanded[sectionIndex]
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.grey),
                          onPressed: () => setState(() =>
                              _sectionExpanded[sectionIndex] =
                                  !_sectionExpanded[sectionIndex]),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: section.selectedSectionTag,
                            decoration:
                                const InputDecoration(labelText: 'Section'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Breakfast', child: Text('Breakfast')),
                              DropdownMenuItem(
                                  value: 'Lunch', child: Text('Lunch')),
                              DropdownMenuItem(
                                  value: 'Dinner', child: Text('Dinner')),
                              DropdownMenuItem(
                                  value: 'Drinks', child: Text('Drinks')),
                              DropdownMenuItem(
                                  value: 'Desserts', child: Text('Desserts')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(
                                    () => section.selectedSectionTag = val);
                              }
                            },
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _sections.length > 1
                                ? () => setState(
                                    () => _sections.removeAt(sectionIndex))
                                : null),
                      ]),
                      if (_sectionExpanded.length > sectionIndex &&
                          _sectionExpanded[sectionIndex]) ...[
                        const SizedBox(height: 14),
                        ...section.items.asMap().entries.map((itemEntry) {
                          final itemIndex = itemEntry.key;
                          final item = itemEntry.value;
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: TextField(
                                          controller: item.nameController,
                                          decoration: const InputDecoration(
                                              hintText: 'Item name'))),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                      width: 90,
                                      child: TextField(
                                          controller: item.priceController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              hintText: 'Price'))),
                                ]),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Colors.grey[300]!)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ElevatedButton.icon(
                                            onPressed: () => _pickImage(
                                                sectionIndex, itemIndex),
                                            icon: const Icon(Icons.image),
                                            label: const Text('Pick image')),
                                        const SizedBox(height: 10),
                                        ElevatedButton.icon(
                                            onPressed: () => _pickVoice(
                                                sectionIndex, itemIndex),
                                            icon: const Icon(Icons.audiotrack),
                                            label:
                                                const Text('Pick voice (mp3)')),
                                      ]),
                                ),
                                const SizedBox(height: 10),
                                Row(children: [
                                  const SizedBox(width: 6),
                                  const Text('Add ingredient',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  IconButton(
                                      icon: const Icon(Icons.add,
                                          color: AppColors.primaryColor),
                                      tooltip: 'Add ingredient',
                                      onPressed: () => _showAddIngredientDialog(
                                          sectionIndex, itemIndex)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Wrap(
                                          spacing: 6,
                                          children: item.ingredients
                                              .map((i) => Chip(label: Text(i)))
                                              .toList())),
                                ]),
                                const SizedBox(height: 10),
                                TextField(
                                    controller: item.descController,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter description'),
                                    maxLines: 2),
                                const SizedBox(height: 10),
                                TextField(
                                    controller: item.howToEatController,
                                    decoration: const InputDecoration(
                                        hintText:
                                            'Instructions (max 100 chars)'),
                                    maxLength: 100),
                                const SizedBox(height: 10),
                                if (item.imageFile != null) ...[
                                  Image.file(item.imageFile!,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover),
                                  TextButton(
                                      onPressed: () =>
                                          _removeImage(sectionIndex, itemIndex),
                                      child: const Text('Remove image')),
                                ],
                                if (item.voiceFile != null) ...[
                                  Text(
                                      'Voice: ${item.voiceFile!.path.split(Platform.pathSeparator).last}'),
                                  TextButton(
                                      onPressed: () =>
                                          _removeVoice(sectionIndex, itemIndex),
                                      child: const Text('Remove voice')),
                                ],
                                const SizedBox(height: 16),
                              ]);
                        }),
                        Row(children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryColor,
                                side: const BorderSide(
                                    color: AppColors.primaryColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 0),
                            icon: const Icon(Icons.add),
                            label: const Text('Add item'),
                            onPressed: () => _addItem(sectionIndex),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryColor,
                                side: const BorderSide(
                                    color: AppColors.primaryColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 0),
                            icon: const Icon(Icons.add),
                            label: const Text('Add section'),
                            onPressed: _addSection,
                          ),
                        ])
                      ]
                    ]),
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
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                // TODO: Implement publish menu logic. We keep a placeholder so file compiles.
              },
              child: const Text('Publish Menu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

  _SectionData({String? selectedSectionTag})
      : selectedSectionTag = selectedSectionTag ?? 'Breakfast';

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
