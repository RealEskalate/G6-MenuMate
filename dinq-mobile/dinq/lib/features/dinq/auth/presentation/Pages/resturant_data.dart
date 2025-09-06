import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/util/theme.dart';
import '../widgets/prefiled.dart';

class RestaurantData extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final PlatformFile? document;

  const RestaurantData({super.key, 
    required this.name,
    required this.phoneNumber,
    required this.document,
  });

  @override
  State<RestaurantData> createState() => _RestaurantDataState();
}

class _RestaurantDataState extends State<RestaurantData> {
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.document;
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Widget _buildFileItem(PlatformFile file) {
    IconData icon;
    Color iconColor;

    if (file.extension == 'pdf') {
      icon = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else {
      icon = Icons.image;
      iconColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(
          file.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          '${(file.size / 1024).toStringAsFixed(1)} KB',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: _removeFile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        padding: const EdgeInsets.all(16), // Add some padding
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40), // Reduced from 60
              const Text('Review & Submit',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Please review and submit your information.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppColors.secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text('Basic Information',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(labelText:'Restaurant Name' , initialText: widget.name),
              const SizedBox(height: 20), // Reduced from 40
              CustomTextField(labelText:'Phone Number' , initialText: widget.phoneNumber),
              const SizedBox(height: 24),

              const Text('Your Legal Document',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              const SizedBox(height: 8),
              const Text('Business License',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppColors.secondaryColor
                ),
              ),
              const SizedBox(height: 16),

              // File display and edit section
              if (_selectedFile != null)
                _buildFileItem(_selectedFile!),

              const SizedBox(height: 16),

              // Change file button
              SizedBox(
                width: 200,
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.swap_horiz, color: AppColors.primaryColor),
                  label: Text(
                    _selectedFile == null ? 'Upload File' : 'Change File',
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save and continue ->',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: (){},
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Extra space at bottom for scrolling
            ],
          ),
        ),
      ),
    );
  }
}