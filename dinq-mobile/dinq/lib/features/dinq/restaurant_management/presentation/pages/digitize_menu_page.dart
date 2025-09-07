// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../../../../../core/util/theme.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/constants.dart';
import 'edit_uploaded_menu_page.dart';

class DigitizeMenuPage extends StatefulWidget {
  const DigitizeMenuPage({super.key});

  @override
  State<DigitizeMenuPage> createState() => _DigitizeMenuPageState();
}

class _DigitizeMenuPageState extends State<DigitizeMenuPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _errorMessage = null; // Clear any previous errors
      });
    }
  }

  Future<void> _chooseFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _errorMessage = null; // Clear any previous errors
      });
    }
  }

  Future<void> _performOCR() async {
    if (_imageFile == null) return;

    print('📸 Starting OCR process...');

    // Validate file before upload
    final fileSize = await _imageFile!.length();
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (fileSize > maxSize) {
      setState(() {
        _errorMessage = 'File size exceeds 5MB limit. Current size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB';
      });
      return;
    }
    print('✅ File size validation passed: ${(fileSize / 1024).toStringAsFixed(2)}KB');

    // Validate file type
    final fileName = _imageFile!.path.split('/').last.toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));

    if (!hasValidExtension) {
      setState(() {
        _errorMessage = 'Invalid file format. Supported formats: JPG, PNG, GIF, BMP, WebP';
      });
      return;
    }
    print('✅ File format validation passed: $fileName');

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    final apiClient = ApiClient(baseUrl: baseUrl);
    print('🌐 Using API client with base URL: $baseUrl');

    try {
      // Step 1: Upload image to /ocr/upload
      print('📤 Step 1: Uploading image to /ocr/upload');
      final uploadResponse = await apiClient.uploadFile('/ocr/upload', _imageFile!, fieldName: 'menuImage');
      print('📥 Upload response: $uploadResponse');

      final jobId = uploadResponse['data']['job_id'];
      print('🎯 Job ID received: $jobId');

      // Step 2: Poll for completion
      print('🔄 Step 2: Starting polling for completion');
      await _pollOCRStatus(apiClient, jobId);
    } catch (e) {
      print('❌ OCR process failed: $e');
      setState(() {
        _isUploading = false;
        _errorMessage = 'OCR failed: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR failed: $e')),
      );
    }
  }

  Future<void> _pollOCRStatus(ApiClient apiClient, String jobId) async {
    const pollInterval = Duration(seconds: 5);
    const maxPolls = 60; // Maximum 5 minutes of polling
    int pollCount = 0;

    print('🔄 Starting OCR status polling for job: $jobId');

    while (pollCount < maxPolls) {
      try {
        print('📡 Poll attempt ${pollCount + 1}/${maxPolls}');
        final response = await apiClient.get('/ocr/$jobId');
        print('📥 Poll response: $response');

        final status = response['data']['status'];
        print('📊 Current status: $status');

        if (status == 'completed') {
          print('✅ OCR completed successfully!');
          setState(() {
            _isUploading = false;
          });

          final menuItems = response['data']['results']['menu_items'];
          print('🍽️ Menu items received: ${menuItems.length} items');

          // Navigate to EditUploadedMenuPage with real data
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditUploadedMenuPage(
                  uploadedImage: _imageFile!,
                  menuItems: menuItems,
                ),
              ),
            );
          }
          break;
        } else if (status == 'processing') {
          // Continue polling
          print('⏳ Still processing, waiting ${pollInterval.inSeconds} seconds...');
          pollCount++;
          await Future.delayed(pollInterval);
        } else if (status == 'failed') {
          throw Exception('OCR processing failed on server');
        } else {
          // Handle other statuses or errors
          throw Exception('OCR processing failed with status: $status');
        }
      } catch (e) {
        print('❌ Polling failed: $e');
        setState(() {
          _isUploading = false;
          _errorMessage = 'OCR processing failed: $e';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OCR processing failed: $e')),
          );
        }
        break;
      }
    }

    if (pollCount >= maxPolls) {
      print('⏰ OCR polling timed out after ${maxPolls * pollInterval.inSeconds} seconds');
      setState(() {
        _isUploading = false;
        _errorMessage = 'OCR processing timed out. Please try again.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OCR processing timed out. Please try again.')),
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
        centerTitle: true,
        title: const Text(
          'Upload Menu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          const SizedBox(height: 18),
          // Camera icon in circle
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(24),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryColor,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Title and subtitle
          const Center(
            child: Text(
              'Digitize  Menu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Take a picture of the printed menu to digitize and\nmake it easily shareable to your customers',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          // Image upload box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.25),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_imageFile == null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ] else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => _imageFile = null),
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Take Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                    onPressed: _takePhoto,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.folder_open,
                      color: AppColors.secondaryColor,
                    ),
                    label: const Text(
                      'Choose from Gallery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _chooseFromGallery,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Tips
          const Text(
            'Tips for better results:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _TipRow(
            icon: Icons.lightbulb,
            text: 'Ensure good lighting and avoid shadows',
          ),
          const SizedBox(height: 8),
          _TipRow(
            icon: Icons.crop_7_5,
            text: 'Capture the entire menu page in frame',
          ),
          const SizedBox(height: 8),
          _TipRow(
            icon: Icons.visibility,
            text: 'Make sure text is clear and readable',
          ),
          const SizedBox(height: 32),

          // Error message display
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Digitize Menu Button
          _imageFile != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isUploading ? Colors.grey : AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Processing...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Digitize Menu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
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
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
