// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:dio/dio';
import 'package:dinq/core/util/theme.dart';
import 'package:dinq/core/constants/constants.dart';
import '../../../../core/error/failures.dart';
import '../widgets/tip_row.dart';
import 'package:dinq/core/error/failure.dart' hide ServerFailure, Failure;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../search/presentation/pages/scanned_menu_page.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true; // Track if we're in scanning mode or upload mode

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
        // Navigate to scanned menu page with the slug
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScannedMenuPage(slug: slug),
        ),
      );
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
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // Handle barcode detection from live camera
  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (!_isScanning) return; // Skip if not in scanning mode
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    // Get first QR code value
    final qrContent = barcodes.first.rawValue;
    print('QrScannerPage: Barcode detected: $qrContent');
    
    if (qrContent == null) {
      print('QrScannerPage: Barcode value is null');
      _showFailure(NotFoundFailure('QR code has no content.'));
      return;
    }
    
    // Pause scanning to prevent multiple detections
    _scannerController.stop();
    setState(() => _isScanning = false);
    
    // Extract restaurant slug (last part of URL)
    final slug = extractRestaurantSlug(qrContent);
    print('QrScannerPage: Extracted slug: $slug');
    
    if (slug == null) {
      _showFailure(NotFoundFailure('Restaurant slug not found in QR code.'));
      // Resume scanning
      _scannerController.start();
      setState(() => _isScanning = true);
      return;
    }
    
    try {
      // Send GET request to backend to verify the menu exists
      final result = await getMenuBySlug(slug);
      if (result is Failure) {
        _showFailure(result);
        // Resume scanning
        _scannerController.start();
        setState(() => _isScanning = true);
        return;
      }
      
      // Navigate to scanned menu page with the slug
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScannedMenuPage(slug: slug),
        ),
      ).then((_) {
        // Resume scanning when returning from menu page
        if (mounted) {
          _scannerController.start();
          setState(() => _isScanning = true);
        }
      });
    } catch (e) {
      print('QrScannerPage: Error processing QR code: $e');
      _showFailure(ServerFailure('Error processing QR code: $e'));
      // Resume scanning
      if (mounted) {
        _scannerController.start();
        setState(() => _isScanning = true);
      }
    }
  }

  // Toggle between scanning and upload modes
  void _toggleMode() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _scannerController.start();
      } else {
        _scannerController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isScanning ? 'Scan QR Code' : 'Upload QR Image'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.whiteColor,
        foregroundColor: AppColors.secondaryColor,
        actions: [
          // Toggle button between scan and upload modes
          IconButton(
            icon: Icon(_isScanning ? Icons.image : Icons.qr_code_scanner),
            onPressed: _toggleMode,
          ),
        ],
      ),
      body: _isScanning
          ? _buildScannerView()
          : _buildUploadView(),
    );
  }

  // Live camera scanner view
  Widget _buildScannerView() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.5), width: 2),
            ),
            clipBehavior: Clip.hardEdge,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeDetected,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Point camera at QR code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: Icon(Icons.image, color: AppColors.secondaryColor),
                  label: const Text('Upload from Gallery instead'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryColor,
                    side: BorderSide(color: AppColors.secondaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _toggleMode,
                ),
                const SizedBox(height: 16),
                const TipRow(icon: Icons.lightbulb_outline, text: 'Ensure good lighting and avoid shadows'),
                const SizedBox(height: 8),
                const TipRow(icon: Icons.crop_free, text: 'Capture the entire QR Code in frame'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Upload image view
  Widget _buildUploadView() {
    return Padding(
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
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: Icon(Icons.qr_code_scanner, color: AppColors.secondaryColor),
                  label: const Text('Switch to Live Scanner'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryColor,
                    side: BorderSide(color: AppColors.secondaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _toggleMode,
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
    );
  }
}
