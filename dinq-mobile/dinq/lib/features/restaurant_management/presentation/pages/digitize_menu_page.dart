// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../../../injection_container.dart' as di;
import '../../data/model/menu_create_model.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/restaurant_event.dart';
import '../bloc/restaurant_state.dart';

class DigitizeMenuPage extends StatefulWidget {
  final String restaurantId;

  const DigitizeMenuPage({
    super.key,
    required this.restaurantId,
  });

  @override
  State<DigitizeMenuPage> createState() => _DigitizeMenuPageState();
}

class _DigitizeMenuPageState extends State<DigitizeMenuPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _errorMessage;
  MenuCreateModel? _createModel;

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _chooseFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _performOCR() async {
    if (_imageFile == null) return;

    // Validate file before upload
    final fileSize = await _imageFile!.length();
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (fileSize > maxSize) {
      setState(() {
        _errorMessage =
            'File size exceeds 5MB limit. Current size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB';
      });
      return;
    }

    // Validate file type
    final fileName = _imageFile!.path.split('/').last.toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final hasValidExtension =
        validExtensions.any((ext) => fileName.endsWith(ext));

    if (!hasValidExtension) {
      setState(() {
        _errorMessage =
            'Invalid file format. Supported formats: JPG, PNG, GIF, BMP, WebP';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Use bloc to upload menu
      context.read<RestaurantBloc>().add(UploadMenuEvent(_imageFile!));
    } catch (e) {
      setState(() {
        _errorMessage = 'OCR failed: $e';
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('OCR failed: $e')));
      }
    }
  }



  Widget _buildEditableCreateForm() {
    final titleController =
        TextEditingController(text: _createModel?.name ?? 'Scanned menu');
    final descController =
        TextEditingController(text: _createModel?.description ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm scanned menu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title')),
        const SizedBox(height: 8),
        TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 4),
        const SizedBox(height: 12),
        const Text('Items (preview):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if ((_createModel?.menuItems ?? []).isEmpty)
          const Text('No items parsed')
        else
          ..._createModel!.menuItems!.map((it) => ListTile(
              title: Text(it.name ?? ''),
              subtitle: Text(it.description ?? ''))),
        const SizedBox(height: 16),
        Row(children: [
          ElevatedButton(
              onPressed: () => setState(() => _createModel = null),
              child: const Text('Back')),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to create menu page with parsed data
              Navigator.of(context).pushNamed(
                AppRoute.createMenuManually,
                arguments: {
                  'restaurantId': widget.restaurantId,
                  'parsedMenuData': _createModel,
                },
              );
            },
            child: const Text('Create Menu'),
          ),
        ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.sl<RestaurantBloc>(),
      child: BlocListener<RestaurantBloc, RestaurantState>(
        listener: (context, state) {
          if (state is MenuCreateLoaded) {
            setState(() {
              _createModel = state.menuCreateModel;
              _isUploading = false;
            });
          } else if (state is RestaurantError) {
            setState(() {
              _errorMessage = state.message;
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OCR failed: ${state.message}')),
            );
          } else if (state is RestaurantLoading) {
            setState(() {
              _isUploading = true;
              _errorMessage = null;
            });
          }
        },
        child: Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Theme.of(context).iconTheme.color),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('Upload Menu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: <Widget>[
          const SizedBox(height: 18),
          Center(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle),
              padding: const EdgeInsets.all(24),
              child: const Icon(Icons.camera_alt,
                  color: AppColors.primaryColor, size: 36),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
              child: Text('Digitize Menu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Take a picture of the printed menu to digitize and\nmake it easily shareable to your customers',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).cardColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_imageFile == null) ...[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.12),
                        shape: BoxShape.circle),
                    padding: const EdgeInsets.all(16),
                    child:
                        const Icon(Icons.image, color: Colors.grey, size: 32),
                  ),
                  const SizedBox(height: 10),
                  const Text('No image selected',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ] else ...[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!,
                          height: 120, fit: BoxFit.cover)),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: () => setState(() => _imageFile = null),
                      child: const Text('Remove',
                          style: TextStyle(color: Colors.red))),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Take Photo',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _takePhoto,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open,
                        color: AppColors.secondaryColor),
                    label: const Text('Choose from Gallery',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.secondaryColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _chooseFromGallery,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Tips for better results:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _TipRow(
              icon: Icons.lightbulb,
              text: 'Ensure good lighting and avoid shadows'),
          const SizedBox(height: 8),
          _TipRow(
              icon: Icons.crop_7_5,
              text: 'Capture the entire menu page in frame'),
          const SizedBox(height: 8),
          _TipRow(
              icon: Icons.visibility,
              text: 'Make sure text is clear and readable'),
          const SizedBox(height: 32),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14)))
              ]),
            ),
            const SizedBox(height: 16),
          ],
          if (_imageFile != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isUploading ? Colors.grey : AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isUploading ? null : _performOCR,
                  child: _isUploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white))),
                            SizedBox(width: 12),
                            Text('Processing...',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        )
                      : const Text('Digitize Menu',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
          ],
          if (_createModel != null) ...[
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildEditableCreateForm()),
          ],
        ],
      ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 14, color: Colors.black87))),
      ],
    );
  }
}
