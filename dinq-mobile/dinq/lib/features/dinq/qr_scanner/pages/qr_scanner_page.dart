// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:dio/dio.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:dinq/core/constants/constants.dart';
import '../../../../core/error/failures.dart';
import '../widgets/tip_row.dart';
// import 'package:dinq/core/error/failure.dart' hide ServerFailure, Failure;

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      print('Picked file: ${pickedFile?.path}');
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _processImage(_selectedImage!);
      }
    } catch (e) {
      print('Image picking error: $e');
      _showFailure(ServerFailure('Failed to pick image: $e'));
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      print('Processing image: ${imageFile.path}');

      // Initialize ML Kit barcode scanner
      final inputImage = InputImage.fromFile(imageFile);
      final barcodeScanner = BarcodeScanner();

      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();

      if (barcodes.isEmpty) {
        _showFailure(NotFoundFailure('No QR code found in image.'));
        return;
      }

      // Get first QR code value
      final qrContent = barcodes.first.rawValue;
      print('QR content: $qrContent');

      if (qrContent == null) {
        _showFailure(NotFoundFailure('QR code has no content.'));
        return;
      }

      // Extract restaurant slug (last part of URL)
      final slug = extractRestaurantSlug(qrContent);
      print('Extracted restaurant slug: $slug');

      if (slug == null) {
        _showFailure(NotFoundFailure('Restaurant slug not found in QR code.'));
        return;
      }

      // Send GET request to backend
      final result = await getMenuBySlug(slug);
      if (result is Failure) {
        _showFailure(result);
      } else {
        // Navigate to menu page (or any success page)
        if (!mounted) return;
        Navigator.pushNamed(context, '/menu_page', arguments: slug);
      }
    } catch (e) {
      print('Error processing image: $e');
      _showFailure(ServerFailure('Error processing image: $e'));
    }
  }

  String? extractRestaurantSlug(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) return null;
    return uri.pathSegments.last;
  }

  Future<dynamic> getMenuBySlug(String slug) async {
    try {
      final dio = Dio();
      final url = '$baseUrl/menus/$slug';
      print('Sending GET request to: $url');

      final response = await dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return NotFoundFailure('No menu found for this restaurant.');
      } else {
        return ServerFailure('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('GET request error: $e');
      return ServerFailure('Failed to connect to server: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFailure(Failure failure) {
    print('Failure: ${failure.runtimeType}: ${failure.message}');
    _showError(failure.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Upload QR Image'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.whiteColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF9F9F9),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _selectedImage == null
                      ? const Icon(Icons.image_outlined, size: 48, color: Color(0xFFBDBDBD))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, height: 120, fit: BoxFit.cover),
                        ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedImage == null ? 'No image selected' : 'Image selected',
                    style: const TextStyle(color: Color(0xFFBDBDBD)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.folder_open, color: AppColors.secondaryColor),
                      label: const Text('Choose from Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryColor,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Tips for better results:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            const TipRow(icon: Icons.lightbulb_outline, text: 'Ensure good lighting and avoid shadows'),
            const SizedBox(height: 12),
            const TipRow(icon: Icons.crop_free, text: 'Capture the entire QR Code in frame'),
          ],
        ),
      ),
    );
  }
}
