import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../../../../core/util/theme.dart';

class GeneratedQrPage extends StatefulWidget {
  final String qrImagePath; // Local asset or network path to QR image
  const GeneratedQrPage({super.key, required this.qrImagePath});

  @override
  State<GeneratedQrPage> createState() => _GeneratedQrPageState();
}

class _GeneratedQrPageState extends State<GeneratedQrPage> {
  String _selectedFormat = '.pdf';

  Future<void> _downloadQr() async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    try {
      final directory = await getExternalStorageDirectory();
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}';

      if (_selectedFormat == '.png') {
        // Copy the PNG file to Downloads
        final file = File(widget.qrImagePath);
        final newPath = '${downloadsDir.path}/$fileName.png';
        await file.copy(newPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Code saved as PNG in Downloads')),
        );
      } else if (_selectedFormat == '.pdf') {
        // Create a PDF with the QR image
        final pdf = pw.Document();
        final imageBytes = await File(widget.qrImagePath).readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image, width: 200, height: 200));
            },
            pageFormat: PdfPageFormat.a4,
          ),
        );

        final pdfFile = File('${downloadsDir.path}/$fileName.pdf');
        await pdfFile.writeAsBytes(await pdf.save());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Code saved as PDF in Downloads')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save QR Code: $e')));
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
          'QR Code',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Image.asset(
              widget.qrImagePath,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          
          // Download button with dropdown
          Center(
            child: SizedBox(
              width: 240,
              child: _DownloadQrButton(
                selectedFormat: _selectedFormat,
                onFormatChanged: (format) {
                  if (format == null) return;
                  setState(() {
                    _selectedFormat = format;
                  });
                },
                onDownload: _downloadQr,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadQrButton extends StatelessWidget {
  final String selectedFormat;
  final ValueChanged<String?> onFormatChanged;
  final VoidCallback onDownload;

  const _DownloadQrButton({
    required this.selectedFormat,
    required this.onFormatChanged,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onDownload,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Download  QR Code',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFormat,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    dropdownColor: AppColors.whiteColor,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    items: const [
                      DropdownMenuItem(value: '.pdf', child: Text('.pdf')),
                      DropdownMenuItem(value: '.png', child: Text('.png')),
                    ],
                    onChanged: onFormatChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
