// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/util/theme.dart';
import '../widgets/tip_row.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          _showFailure(const ServerFailure('Camera permission denied'));
          return;
        }
      } else {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          _showFailure(const ServerFailure('Gallery permission denied'));
          return;
        }
      }

      final pickedFile = await _picker.pickImage(source: source);
      print('Picked file: \\${pickedFile?.path}');
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
      print('Processing image: \\${imageFile.path}');
      // Extract QR code from image
      final controller = MobileScannerController();
      List<Barcode> capturedBarcodes = [];
      late StreamSubscription<BarcodeCapture> subscription;

      Completer<void> completer = Completer();

      subscription = controller.barcodes.listen((barcodeCapture) {
        capturedBarcodes.addAll(barcodeCapture.barcodes);
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      bool success = await controller.analyzeImage(imageFile.path);
      if (success) {
        await completer.future;
      }
      await subscription.cancel();
      controller.dispose();

      String? qrContent;
      if (capturedBarcodes.isNotEmpty) {
        qrContent = capturedBarcodes.first.rawValue;
      }
      print('QR content: $qrContent');
      if (qrContent == null) {
        _showFailure(const NotFoundFailure('No QR code found in image.'));
        return;
      }

      // Extract branchId from URL
      String? branchId = extractBranchId(qrContent);
      print('Extracted branchId: $branchId');
      if (branchId == null) {
        _showFailure(const NotFoundFailure('Branch ID not found in QR code.'));
        return;
      }

      // Send GET request to backend
      final menuResult = await checkMenuExists(branchId);
      if (menuResult is ServerFailure) {
        _showFailure(menuResult);
      } else if (menuResult is NotFoundFailure) {
        _showFailure(menuResult);
      } else if (menuResult == true) {
        if (!mounted) return;
        Navigator.pushNamed(context, '/scanned-menu', arguments: branchId);
      } else {
        _showFailure(
          const NotFoundFailure('No menu published for this branch.'),
        );
      }
    } catch (e) {
      print('Error processing image: $e');
      _showFailure(ServerFailure('Error processing image: $e'));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFailure(Failure failure) {
    print('Failure: ${failure.runtimeType}: ${failure.message}');
    _showError(failure.message);
  }

  String? extractBranchId(String? url) {
    final uri = Uri.tryParse(url ?? '');
    if (uri == null) return null;
    final segments = uri.pathSegments;
    final idx = segments.indexOf('branch');
    if (idx != -1 && idx + 1 < segments.length) {
      return segments[idx + 1];
    }
    return null;
  }

  Future<dynamic> checkMenuExists(String branchId) async {
    try {
      final dio = Dio();
      final url =
          'https://dineq-backend.onrender.com/api/v1/menu/branch/$branchId';
      print('Sending GET request to: $url');
      final response = await dio.get(url);
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return const NotFoundFailure('No menu published for this branch.');
      } else {
        return ServerFailure('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('GET request error: $e');
      return ServerFailure('Failed to connect to server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
=======

>>>>>>> mobile-merge-UI
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
                      ? const Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Color(0xFFBDBDBD),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedImage == null
                        ? 'No image selected'
                        : 'Image selected',
                    style: const TextStyle(color: Color(0xFFBDBDBD)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.folder_open,
                        color: AppColors.secondaryColor,
                      ),
                      label: const Text('Choose from Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryColor,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Tips for better results:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const TipRow(
              icon: Icons.lightbulb_outline,
              text: 'Ensure good lighting and avoid shadows',
            ),
            const SizedBox(height: 12),
            const TipRow(
              icon: Icons.crop_free,
              text: 'Capture the entire QR Code in frame',
            ),
            const SizedBox(height: 12),
<<<<<<< HEAD
=======

>>>>>>> mobile-merge-UI
          ],
        ),
      ),
    );
  }
}
