import 'package:flutter/material.dart';
import 'package:dinq/core/util/theme.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/resturant_data.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_TextFields.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:iconsax/iconsax.dart';

class ResturantRegistration extends StatefulWidget {
  const ResturantRegistration({super.key});

  @override
  State<ResturantRegistration> createState() => _ResturantRegistrationState();
}

class _ResturantRegistrationState extends State<ResturantRegistration> {
  PlatformFile? _selectedFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
          SnackBar(
            content: Text('Please upload one document'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // All validations passed, navigate to review page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantData(
            name: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            document: _selectedFile,
          ),
        ),
      );
    }
  }

  void _skipForNow() {
    // Navigate to home page (replace with your actual home page route)
    Navigator.pushReplacementNamed(context, '/home');
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
            Text(
              "Restaurant Information",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Basic Information",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            LoginTextfields(
              controller: _nameController,
              labeltext: "Restaurant Name",
              hintText: "Enter Restaurant name",
              errorText: _nameError,
            ),
            const SizedBox(height: 20),
            LoginTextfields(
              controller: _phoneController,
              labeltext: "Phone Number",
              hintText: "+251",
              isPhoneNumber: true,
              errorText: _phoneError,
            ),
            const SizedBox(height: 30),
            Text(
              "Upload Your Legal Documents",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Supported formats: JPG, PNG, PDF",
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
                  icon: Icon(Icons.upload_file, color: AppColors.primaryColor),
                  label: Text(
                    "Browse File",
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            if (_selectedFile == null)
              const SizedBox(height: 10),
            if (_selectedFile == null)
              Text(
                "Tap to select a file",
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
              Text(
                "Selected Document:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
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
                  icon: Icon(Icons.swap_horiz, color: AppColors.primaryColor),
                  label: Text(
                    "Change File",
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primaryColor),
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
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Save and continue ->",
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
                child: Text(
                  "Skip for now",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontFamily: 'Inter'
                  ),
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
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(
          file.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          '${(file.size / 1024).toStringAsFixed(1)} KB',
          style: TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: _removeFile,
        ),
      ),
    );
  }
}