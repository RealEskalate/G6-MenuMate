import 'package:flutter/material.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/resturant_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../search/presentation/pages/home_page.dart';
import '../bloc/manger/manger__event.dart';
import '../bloc/manger/manger_bloc.dart';
import '../bloc/manger/manger_state.dart';
import 'email_verfiction.dart';
import 'verify_page.dart'; // make sure you import the state

class ResturantRegistration extends StatefulWidget {
  const ResturantRegistration({super.key});

  @override
  State<ResturantRegistration> createState() => _ResturantRegistrationState();
}

class _ResturantRegistrationState extends State<ResturantRegistration> {
  PlatformFile? _verificationDoc;
  PlatformFile? _logoFile;
  PlatformFile? _coverFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _nameError;
  String? _phoneError;

  Future<void> _pickFile(Function(PlatformFile) onSelected) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        onSelected(result.files.first);
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

  void _removeVerificationDoc() => setState(() => _verificationDoc = null);
  void _removeLogo() => setState(() => _logoFile = null);
  void _removeCover() => setState(() => _coverFile = null);

  bool _validateForm() {
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      setState(() => _nameError = 'Please enter restaurant name');
      isValid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (_phoneController.text.isEmpty) {
      setState(() => _phoneError = 'Please enter phone number');
      isValid = false;
    } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(_phoneController.text)) {
      setState(() => _phoneError = 'Please enter a valid phone number');
      isValid = false;
    } else {
      setState(() => _phoneError = null);
    }

    return isValid;
  }

  void _submitForm() {
    if (_validateForm()) {
      if (_verificationDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload one document'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      context.read<MangerBloc>().add(ResturantEvent(
            resturant_name: _nameController.text.trim(),
            resturant_phone: _phoneController.text.trim(),
            verification_docs: _verificationDoc!,
            logo_image: _logoFile,
            cover_image: _coverFile,
          ));
    }
  }

  void _skipForNow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
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
      backgroundColor: Colors.white,
      body: BlocConsumer<MangerBloc, MangerState>(
        listener: (context, state) {
          if (state is MangerRegistered) {
            Navigator.pushReplacementNamed(context, '/verify');
          } else if (state is MangerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MangerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // your form stays unchanged
          return SingleChildScrollView(
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

                // Name
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Restaurant Name",
                    hintText: "Enter Restaurant name",
                    errorText: _nameError,
                  ),
                ),
                const SizedBox(height: 20),

                // Phone
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "+251",
                    errorText: _phoneError,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),

                // ---------- Legal Document ----------
                Text("Upload Your Legal Documents",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87)),
                const SizedBox(height: 10),
                if (_verificationDoc == null)
                  _buildUploadButton("Browse File", () {
                    _pickFile((file) => setState(() => _verificationDoc = file));
                  })
                else
                  _buildFileItem(_verificationDoc!, _removeVerificationDoc),

                const SizedBox(height: 30),

                // ---------- Logo ----------
                Text("Upload Logo",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87)),
                const SizedBox(height: 10),
                if (_logoFile == null)
                  _buildUploadButton("Browse Logo (optional)", () {
                    _pickFile((file) => setState(() => _logoFile = file));
                  })
                else
                  _buildFileItem(_logoFile!, _removeLogo),

                const SizedBox(height: 30),

                // ---------- Cover Image ----------
                Text("Upload Cover Image (optional)",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87)),
                const SizedBox(height: 10),
                if (_coverFile == null)
                  _buildUploadButton("Browse Cover", () {
                    _pickFile((file) => setState(() => _coverFile = file));
                  })
                else
                  _buildFileItem(_coverFile!, _removeCover),

                const SizedBox(height: 30),

                // Submit button
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
                      "Save and continue ->",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

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
                          fontFamily: 'Inter'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- Helpers ----------
  Widget _buildUploadButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.upload_file, color: AppColors.primaryColor),
        label: Text(text, style: TextStyle(color: AppColors.primaryColor)),
      ),
    );
  }

  Widget _buildFileItem(PlatformFile file, VoidCallback onRemove) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(Icons.image, color: Colors.blue, size: 32),
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
          onPressed: onRemove,
        ),
      ),
    );
  }
}
