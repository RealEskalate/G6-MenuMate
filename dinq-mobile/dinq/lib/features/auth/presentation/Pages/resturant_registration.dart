import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../widgets/Login_TextFields.dart';

class RestaurantRegistration extends StatefulWidget {
  const RestaurantRegistration({super.key});

  @override
  State<RestaurantRegistration> createState() => _RestaurantRegistrationState();
}

class _RestaurantRegistrationState extends State<RestaurantRegistration> {
  PlatformFile? _selectedFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _nameError;
  String? _phoneError;

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

  bool _validateForm() {
    bool isValid = true;

    // Validate name
    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = 'Please enter restaurant name';
      });
      isValid = false;
    } else {
      setState(() {
        _nameError = null;
      });
    }

    // Validate phone number
    if (_phoneController.text.isEmpty) {
      setState(() {
        _phoneError = 'Please enter phone number';
      });
      isValid = false;
    } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(_phoneController.text)) {
      setState(() {
        _phoneError = 'Please enter a valid phone number';
      });
      isValid = false;
    } else {
      setState(() {
        _phoneError = null;
      });
    }

    return isValid;
  }

  void _submitForm() {
    if (_validateForm()) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload one document'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // All validations passed, navigate to review page
      Navigator.pushNamed(
        context,
        AppRoute.restaurantData,
        arguments: {
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'document': _selectedFile,
        },
      );
    }
  }

  void _skipForNow() {
    // Navigate to onboarding page
    Navigator.pushReplacementNamed(context, AppRoute.home);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Restaurant Information',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Basic Information',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            LoginTextfields(
              controller: _nameController,
              labeltext: 'Restaurant Name',
              hintText: 'Enter Restaurant name',
              errorText: _nameError,
            ),
            const SizedBox(height: 20),
            LoginTextfields(
              controller: _phoneController,
              labeltext: 'Phone Number',
              hintText: '+251',
              isPhoneNumber: true,
              errorText: _phoneError,
            ),
            const SizedBox(height: 30),
            const Text(
              'Upload Your Legal Documents',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Supported formats: JPG, PNG, PDF',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // File upload button - only show if no file is selected
            if (_selectedFile == null)
              SizedBox(
                width: double.infinity,
                height: 200,
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file,
                      color: AppColors.primaryColor),
                  label: const Text(
                    'Browse File',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            if (_selectedFile == null) const SizedBox(height: 10),
            if (_selectedFile == null)
              Text(
                'Tap to select a file',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 30),

            // Show selected file if one is chosen
            if (_selectedFile != null) ...[
              const Text(
                'Selected Document:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              _buildFileItem(_selectedFile!),
              const SizedBox(height: 20),

              // Option to change file
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.swap_horiz,
                      color: AppColors.primaryColor),
                  label: const Text(
                    'Change File',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Submit button
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
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

            // Skip for now button moved to bottom
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _skipForNow,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontFamily: 'Inter'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    // Determine file type icon
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
}
