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
  File? _initialImage;

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
    if (!_isEditing) return;
    final firstChanged =
        _firstNameController.text.trim() != (_initialFirstName ?? '');
    final lastChanged =
        _lastNameController.text.trim() != (_initialLastName ?? '');
    final imageChanged = _selectedImage != null;
    final changed = firstChanged || lastChanged || imageChanged;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _initialFirstName = _firstNameController.text;
      _initialLastName = _lastNameController.text;
      _initialImage = _selectedImage;
      _hasChanges = false;
    });
  }

  void _cancelEditing() {
    setState(() {
      _firstNameController.text = _initialFirstName ?? '';
      _lastNameController.text = _initialLastName ?? '';
      _selectedImage = _initialImage;
      _isEditing = false;
      _hasChanges = false;
    });
  }

  void _saveChanges() {
    if (!_hasChanges) return;
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
      _initialImage = _selectedImage;
      _isEditing = false;
      _hasChanges = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await TokenManager.clearTokens();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
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
      cursorColor: Colors.orange, // Orange cursor when typing
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? Colors.orange : Colors.grey[600],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        // Default border (when not focused)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: enabled ? Colors.orange : Colors.grey[300]!,
            width: enabled ? 1.5 : 1,
          ),
        ),
        // Enabled but not focused
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: enabled ? Colors.orange : Colors.grey[300]!,
            width: enabled ? 1.5 : 1,
          ),
        ),
        // FOCUSED - This overrides the default blue highlight
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),
        // Disabled (email field)
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _hasChanges ? _saveChanges : _cancelEditing,
              child: Text(
                _hasChanges ? 'Save' : 'Done',
                style: TextStyle(
                  color: _hasChanges ? Colors.orange : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _startEditing,
            ),
        ],
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

          if (state is! AuthLoggedIn) return const SizedBox();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Profile Image ─────────────────────────────────
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : const AssetImage("assets/images/profile.jpg")
                              as ImageProvider,
                    ),
                    if (_isEditing)
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Personal Info Card ────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildField(
                      controller: _firstNameController,
                      label: "First Name",

                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _lastNameController,
                      label: "Last Name",
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _emailController,
                      label: "Email",
                      enabled: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Action Buttons (only in edit mode) ───────────
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelEditing,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _hasChanges ? _saveChanges : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _hasChanges ? Colors.orange : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // ─── Account Actions Card ─────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        "Change Password",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 72),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        "Sign Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}