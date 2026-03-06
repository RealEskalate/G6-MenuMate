import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/network/token_manager.dart';
import '../../../../../../core/util/theme.dart';
import '../../../../auth/presentation/bloc/registration/registration_bloc.dart';
import '../../../../auth/presentation/bloc/registration/registration_event.dart';
import '../../../../auth/presentation/bloc/registration/registration_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  String? _initialFirstName;
  String? _initialLastName;

  bool _hasChanges = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();

    _firstNameController.addListener(_checkForChanges);
    _lastNameController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      _checkForChanges();
    }
  }

  void _checkForChanges() {
    final firstChanged =
        _firstNameController.text.trim() != (_initialFirstName ?? '');
    final lastChanged =
        _lastNameController.text.trim() != (_initialLastName ?? '');
    final imageChanged = _selectedImage != null;

    final changed = firstChanged || lastChanged || imageChanged;

    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  void _saveChanges() {
    final updatedFirst = _firstNameController.text.trim();
    final updatedLast = _lastNameController.text.trim();

    context.read<AuthBloc>().add(
          UpdateUserProfileEvent(
            firstName: updatedFirst,
            lastName: updatedLast,
            image: _selectedImage,
          ),
        );

    setState(() {
      _initialFirstName = updatedFirst;
      _initialLastName = updatedLast;
      _selectedImage = null;
      _hasChanges = false;
      _isEditing = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await TokenManager.clearTokens();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is AuthLoggedIn) {
            final user = state.user;

            _initialFirstName ??= user.firstName;
            _initialLastName ??= user.lastName;

            if (_firstNameController.text.isEmpty) {
              _firstNameController.text = user.firstName ?? '';
            }

            if (_lastNameController.text.isEmpty) {
              _lastNameController.text = user.lastName ?? '';
            }

            if (_emailController.text.isEmpty) {
              _emailController.text = user.email;
            }
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthLoggedIn) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 25),

                /// PROFILE IMAGE
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : const AssetImage("assets/images/profile.jpg")
                                as ImageProvider,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// EDIT BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// FIRST NAME
                _buildField(
                  controller: _firstNameController,
                  label: "First Name",
                  enabled: _isEditing,
                ),

                const SizedBox(height: 15),

                /// LAST NAME
                _buildField(
                  controller: _lastNameController,
                  label: "Last Name",
                  enabled: _isEditing,
                ),

                const SizedBox(height: 15),

                /// EMAIL (NOT EDITABLE)
                _buildField(
                  controller: _emailController,
                  label: "Email",
                  enabled: false,
                ),

                const SizedBox(height: 25),

                /// SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _hasChanges ? AppColors.primaryColor : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _hasChanges ? _saveChanges : null,
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// ACCOUNT SETTINGS
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.lock,
                          color: AppColors.primaryColor,
                        ),
                        title: const Text("Change Password"),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          "Sign Out",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}