// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/util/theme.dart';

class EditMenuItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const EditMenuItemPage({super.key, required this.item});

  @override
  State<EditMenuItemPage> createState() => _EditMenuItemPageState();
}

class _EditMenuItemPageState extends State<EditMenuItemPage> {
  File? voiceFile;

  late String selectedSectionTag;
  late TextEditingController itemNameController;
  late TextEditingController priceController;
  late TextEditingController descController;
  final TextEditingController howToEatController = TextEditingController();
  List<String> ingredients = [];

  @override
  void initState() {
    super.initState();
    itemNameController = TextEditingController(text: widget.item['name'] ?? '');
    priceController = TextEditingController(text: widget.item['price'] ?? '');
    descController = TextEditingController(text: widget.item['desc'] ?? '');
    selectedSectionTag = widget.item['section'] ?? 'Breakfast';
    // If you want to support ingredients, add them to the item map
    if (widget.item['ingredients'] != null &&
        widget.item['ingredients'] is List) {
      ingredients = List<String>.from(widget.item['ingredients']);
    }
  }

  Future<void> _pickVoice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        voiceFile = File(result.files.single.path!);
      });
    }
  }

  void _removeVoice() {
    setState(() {
      voiceFile = null;
    });
  }

  void _addIngredient(String ingredient) {
    setState(() {
      ingredients.add(ingredient);
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      ingredients.remove(ingredient);
    });
  }

  // State for extracted images and selected image
  List<String> extractedImageUrls = [];
  String? selectedImageUrl;
  File? uploadedImageFile;

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
        title: Text(
          'Edit Item',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.secondaryColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Card(
            color: AppColors.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Section 1',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.secondaryColor,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedSectionTag,
                              decoration: InputDecoration(
                                hintText: 'Select section',
                                hintStyle: TextStyle(color: Colors.black54),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
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
                                    selectedSectionTag = val;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: itemNameController,
                              decoration: InputDecoration(
                                hintText: 'Enter item name',
                                hintStyle: TextStyle(color: Colors.black54),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: priceController,
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: TextStyle(color: Colors.black54),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Image upload logic: show label and two options
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Image',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor,
                          ),
                    ),
                  ),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.image_search),
                          label: const Text('Extract from menu photo'),
                          onPressed: () async {
                            // Simulate backend call to get 6 images
                            // Replace this with your actual backend call
                            setState(() {
                              extractedImageUrls = [
                                'https://via.placeholder.com/120x120?text=1',
                                'https://via.placeholder.com/120x120?text=2',
                                'https://via.placeholder.com/120x120?text=3',
                                'https://via.placeholder.com/120x120?text=4',
                                'https://via.placeholder.com/120x120?text=5',
                                'https://via.placeholder.com/120x120?text=6',
                              ];
                              selectedImageUrl = null;
                              uploadedImageFile = null;
                            });
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Choose from gallery'),
                          onPressed: () async {
                            // Normal image upload logic
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              allowMultiple: false,
                            );
                            if (result != null &&
                                result.files.single.path != null) {
                              setState(() {
                                uploadedImageFile = File(
                                  result.files.single.path!,
                                );
                                extractedImageUrls = [];
                                selectedImageUrl = null;
                              });
                            }
                          },
                        ),
                        if (extractedImageUrls.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Select an extracted image:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: extractedImageUrls.map((url) {
                              final isSelected = selectedImageUrl == url;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImageUrl = url;
                                    uploadedImageFile = null;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.network(
                                    url,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        if (uploadedImageFile != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Selected image:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              uploadedImageFile!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...ingredients.map(
                        (ingredient) => Chip(
                          label: Text(ingredient),
                          onDeleted: () => _removeIngredient(ingredient),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Add ingredient',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryColor,
                            ),
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
                              final controller = TextEditingController();
                              return AlertDialog(
                                title: Text(
                                  'Add Ingredient',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                content: TextField(
                                  controller: controller,
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, controller.text),
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
                            _addIngredient(ingredient.trim());
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      hintText: 'Enter description',
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: howToEatController,
                    decoration: InputDecoration(
                      hintText: 'Instructions (max 100 chars)',
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Voice Explanation',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryColor,
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
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (voiceFile == null)
                          TextButton.icon(
                            icon: const Icon(
                              Icons.upload_file,
                              color: AppColors.primaryColor,
                            ),
                            label: Text(
                              'Upload mp3 (max 10MB)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.secondaryColor),
                            ),
                            onPressed: _pickVoice,
                          )
                        else ...[
                          Expanded(
                            child: Text(
                              voiceFile!.path
                                  .split(Platform.pathSeparator)
                                  .last,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _removeVoice,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
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
                // TODO: Save changes
              },
              child: Text(
                'Save changes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
