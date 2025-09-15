import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_management_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_management_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_management_state.dart';
import '../../../restaurant_management/presentation/pages/restaurant_details_page.dart';

class RestaurantRegistration extends StatefulWidget {
  const RestaurantRegistration({super.key});

  @override
  State<RestaurantRegistration> createState() => _RestaurantRegistrationState();
}

class _RestaurantRegistrationState extends State<RestaurantRegistration> {
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;
  File? _bannerImage;
  PlatformFile? _selectedFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  String selectedCuisine = 'Ethiopian';
  String selectedCurrency = 'ETB';
  String selectedLanguage = 'English';

  String? _nameError;
  String? _descriptionError;
  String? _emailError;
  String? _phoneError;
  String? _locationError;

  final List<String> cuisines = [
    'Ethiopian',
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'American',
    'French',
    'Japanese',
    'Thai',
    'Other'
  ];

  final List<String> currencies = ['ETB', 'USD', 'EUR'];
  final List<String> languages = ['English', 'Amharic', 'Oromo'];

  bool _isLoading = false;

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

  Future<void> _pickImage(bool isLogo) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoImage = File(pickedFile.path);
        } else {
          _bannerImage = File(pickedFile.path);
        }
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate name - required
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

    // Validate phone number - required
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

    // Clear other error states since they're now optional
    setState(() {
      _emailError = null;
      _locationError = null;
      _descriptionError = null;
    });

    return isValid;
  }

  void _submitForm() async {
    if (_validateForm()) {
      setState(() => _isLoading = true);

      try {
        final formData = FormData.fromMap({
          'restaurant_name': _nameController.text,
          'restaurant_phone': _phoneController.text,
          // Optional fields - only include if they have values
          if (_descriptionController.text.isNotEmpty)
            'about': _descriptionController.text,
          if (_locationController.text.isNotEmpty)
            'location': _locationController.text,
          if (_websiteController.text.isNotEmpty)
            'website': _websiteController.text,
          // 'cuisine_type': selectedCuisine,
          // 'default_currency': selectedCurrency,
          // 'default_language': selectedLanguage,
          if (_logoImage != null)
            'logo_image': await MultipartFile.fromFile(_logoImage!.path),
          if (_bannerImage != null)
            'cover_image': await MultipartFile.fromFile(_bannerImage!.path),
        });

        context
            .read<RestaurantManagementBloc>()
            .add(CreateRestaurantEvent(formData));
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating restaurant: $e')),
        );
      }
    }
  }

  void _skipForNow() {
    // Navigate back to previous screen
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register Restaurant'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<RestaurantManagementBloc, RestaurantManagementState>(
        listener: (context, state) {
          if (state is RestaurantCreated) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Restaurant created successfully!')),
            );
            // Navigate to restaurant details page to complete setup
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RestaurantDetailsPage(restaurant: state.restaurant),
              ),
            );
          } else if (state is RestaurantManagementError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  _buildTextField(
                      'Restaurant Name', _nameController, _nameError,
                      isRequired: true),
                  const SizedBox(height: 15),
                  _buildDropdownField('Cuisine Type', cuisines, selectedCuisine,
                      (value) => setState(() => selectedCuisine = value!),
                      isRequired: false),
                  const SizedBox(height: 24),
                  const Text(
                    'Logo (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildImageUpload(isLogo: true),
                  const SizedBox(height: 24),
                  const Text(
                    'Cover Banner (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildImageUpload(isWide: true, isLogo: false),
                  const SizedBox(height: 24),
                  _buildTextField('Description (Optional)',
                      _descriptionController, _descriptionError),
                  const SizedBox(height: 15),
                  _buildTextField(
                      'Email (Optional)', _emailController, _emailError),
                  const SizedBox(height: 15),
                  _buildTextField('Phone Number', _phoneController, _phoneError,
                      isPhoneNumber: true, isRequired: true),
                  const SizedBox(height: 15),
                  _buildTextField('Location (Optional)', _locationController,
                      _locationError),
                  const SizedBox(height: 15),
                  _buildTextField(
                      'Website (Optional)', _websiteController, null),
                  const SizedBox(height: 15),
                  _buildDropdownField(
                      'Default Currency',
                      currencies,
                      selectedCurrency,
                      (value) => setState(() => selectedCurrency = value!)),
                  const SizedBox(height: 15),
                  _buildDropdownField(
                      'Default Language',
                      languages,
                      selectedLanguage,
                      (value) => setState(() => selectedLanguage = value!)),
                  const SizedBox(height: 30),
                  const Text(
                    'Upload Your Legal Documents (Optional)',
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
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Restaurant',
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
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String? errorText,
      {bool isRequired = false, bool isPhoneNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            children: isRequired
                ? [
                    const TextSpan(
                        text: ' *', style: TextStyle(color: Colors.red))
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType:
              isPhoneNumber ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      String selectedValue, Function(String?) onChanged,
      {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            children: isRequired
                ? [
                    const TextSpan(
                        text: ' *', style: TextStyle(color: Colors.red))
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildImageUpload({required bool isLogo, bool isWide = false}) {
    final image = isLogo ? _logoImage : _bannerImage;
    final title = isLogo ? 'Upload Logo' : 'Upload Cover Banner';

    return GestureDetector(
      onTap: () => _pickImage(isLogo),
      child: Container(
        height: isWide ? 150 : 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(color: Colors.grey)),
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
