import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/util/theme.dart';
import '../../../../../injection_container.dart' as di;
import '../../../auth/presentation/Pages/Register_page.dart';
import '../../../auth/presentation/Pages/login_page.dart';
import '../../../auth/presentation/bloc/user_bloc.dart';
import '../../../auth/presentation/bloc/user_event.dart';
import '../../../auth/presentation/bloc/user_state.dart';

class ProfilePage extends StatefulWidget {
  /// When embedded inside a shell that provides its own navigation bar,
  /// set this to false to avoid rendering the owner nav bar duplicate.
  final bool showOwnerNavBar;

  const ProfilePage({super.key, this.showOwnerNavBar = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
      print('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.sl<UserBloc>(),
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) async {
          if (state is UserLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ));
            // Close any login/register routes and refresh profile view
            // tokens and user are already cached by the repository
          } else if (state is UserRegistered) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: Colors.green,
            ));
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Profile',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          body: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
            if (state is UserLoggedIn || state is UserRegistered) {
              final user = (state is UserLoggedIn)
                  ? state.user
                  : (state as UserRegistered).user;
              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  const SizedBox(height: 16),
                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!) as ImageProvider
                              : const AssetImage('assets/images/profile.jpg'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name & Email
                  Center(
                    child: Column(
                      children: [
                        Text(
                          user.firstName + ' ' + user.lastName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Account Settings Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.lock,
                            color: AppColors.primaryColor,
                          ),
                          title: const Text(
                            'Change Password',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onTap: () {},
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEAEAEA),
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () async {
                            context.read<UserBloc>().add(LogoutUserEvent());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            }

            // Not logged in - show actions
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      const Text('Welcome',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                          'Sign in or create an account to get the best experience'),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const LoginPage()));
                          },
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const RegisterPage()));
                          },
                          child: const Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
