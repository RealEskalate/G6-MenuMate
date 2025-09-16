import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/restaurant.dart';
import '../bloc/restaurant_management_bloc.dart';
import '../bloc/restaurant_management_event.dart';
import '../bloc/restaurant_management_state.dart';

class RestaurantDetailsPage extends StatefulWidget {
  const RestaurantDetailsPage({super.key});

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;
  File? _bannerImage;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController locationController;
  late TextEditingController websiteController;
  String selectedCuisine = 'Ethiopian';
  String selectedCurrency = 'ETB';
  String selectedLanguage = 'English';
  String logoPath = '';
  String bannerPath = '';

  @override
  void initState() {
    super.initState();
    // Check if restaurant is selected, if not load owner restaurants
    final bloc = context.read<RestaurantManagementBloc>();
    if (bloc.selectedRestaurant == null) {
      bloc.add(const LoadOwnerRestaurants());
    }
  }

  @override
  void dispose() {
    // Dispose controllers if initialized
    try {
      nameController.dispose();
    } catch (_) {}
    try {
      descriptionController.dispose();
    } catch (_) {}
    try {
      emailController.dispose();
    } catch (_) {}
    try {
      phoneController.dispose();
    } catch (_) {}
    try {
      locationController.dispose();
    } catch (_) {}
    try {
      websiteController.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _initializeControllers(Restaurant restaurant) {
    nameController = TextEditingController(text: restaurant.restaurantName);
    descriptionController = TextEditingController(text: restaurant.about);
    emailController = TextEditingController(text: restaurant.email);
    phoneController = TextEditingController(text: restaurant.restaurantPhone);
    locationController = TextEditingController(text: restaurant.location);
    websiteController = TextEditingController(text: restaurant.website ?? '');
    selectedCuisine = restaurant.cuisineType ?? 'Ethiopian';
    selectedCurrency = restaurant.defaultCurrency ?? 'ETB';
    selectedLanguage = restaurant.defaultLanguage ?? 'English';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<RestaurantManagementBloc, RestaurantManagementState>(
        builder: (context, state) {
          final selectedRestaurant =
              context.read<RestaurantManagementBloc>().selectedRestaurant;

          if (selectedRestaurant == null) {
            if (state is RestaurantManagementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OwnerRestaurantsLoaded &&
                state.restaurants.isNotEmpty) {
              // Auto-select first restaurant
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context
                    .read<RestaurantManagementBloc>()
                    .add(SelectRestaurant(state.restaurants.first));
              });
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('No restaurant selected'));
            }
          }

          // Initialize controllers if not already done
          if (nameController.text.isEmpty) {
            _initializeControllers(selectedRestaurant);
          }

          return BlocListener<RestaurantManagementBloc,
              RestaurantManagementState>(
            listener: (context, state) {
              if (state is RestaurantManagementSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is RestaurantManagementError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
              }
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant Details Section
                      const Text(
                        'Restaurant Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Restaurant Name', nameController),
                      const SizedBox(height: 16),
                      _buildDropdownField('Cuisine Type'),
                      const SizedBox(height: 24),
                      const Text(
                        'Logo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildImageUpload(isLogo: true),
                      const SizedBox(height: 24),
                      const Text(
                        'Cover Banner',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildImageUpload(isWide: true, isLogo: false),
                      const SizedBox(height: 24),
                      _buildTextField('Description', descriptionController),
                      const SizedBox(height: 16),
                      _buildTextField('Email', emailController),
                      const SizedBox(height: 16),
                      _buildTextField('Phone', phoneController),
                      const SizedBox(height: 16),
                      _buildTextField('Location', locationController),
                      const SizedBox(height: 16),
                      _buildTextField('Website', websiteController),
                      const SizedBox(height: 16),
                      _buildDropdownField('Default Currency'),
                      const SizedBox(height: 16),
                      _buildDropdownField('Default Language'),
                      const SizedBox(height: 16),
                      // Settings Section (merged from restaurant profile page)
                      const Text(
                        'Settings',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsItem(
                        title: 'Opening and closing hours',
                        leadingIcon: Icons.access_time,
                        onTap: () {
                          // TODO: Implement opening hours functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Opening hours feature coming soon!')),
                          );
                        },
                      ),
                      const Divider(),
                      _buildSettingsItem(
                        title: 'QR Code Management',
                        leadingIcon: Icons.qr_code,
                        onTap: () {
                          // TODO: Navigate to QR code management
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('QR Code management coming soon!')),
                          );
                        },
                      ),
                      const Divider(),
                      _buildSettingsItem(
                        title: 'Billing & Payments',
                        leadingIcon: Icons.payment,
                        onTap: () {
                          // TODO: Navigate to billing page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Billing feature coming soon!')),
                          );
                        },
                      ),
                      const Divider(),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateRestaurant,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Update Restaurant',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<RestaurantManagementBloc,
                    RestaurantManagementState>(
                  builder: (context, state) {
                    if (state is RestaurantManagementLoading) {
                      return Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    List<String> items;
    String currentValue;

    switch (label) {
      case 'Cuisine Type':
        items = const [
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
        currentValue = selectedCuisine;
        break;
      case 'Default Currency':
        items = const ['ETB', 'USD', 'EUR'];
        currentValue = selectedCurrency;
        break;
      case 'Default Language':
        items = const ['English', 'Amharic', 'Oromo'];
        currentValue = selectedLanguage;
        break;
      default:
        items = const ['Ethiopian'];
        currentValue = selectedCuisine;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              isExpanded: true,
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  switch (label) {
                    case 'Cuisine Type':
                      selectedCuisine = value!;
                      break;
                    case 'Default Currency':
                      selectedCurrency = value!;
                      break;
                    case 'Default Language':
                      selectedLanguage = value!;
                      break;
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload({bool isWide = false, bool isLogo = true}) {
    File? image = isLogo ? _logoImage : _bannerImage;

    return GestureDetector(
      onTap: () async {
        final XFile? pickedFile =
            await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            if (isLogo) {
              _logoImage = File(pickedFile.path);
              logoPath = pickedFile.path;
            } else {
              _bannerImage = File(pickedFile.path);
              bannerPath = pickedFile.path;
            }
          });
        }
      },
      child: Container(
        height: isWide ? 120 : 100,
        width: isWide ? double.infinity : 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          image: image != null
              ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload photo',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  void _updateRestaurant() async {
    final selectedRestaurant =
        context.read<RestaurantManagementBloc>().selectedRestaurant;
    if (selectedRestaurant == null) return;

    try {
      final formData = FormData.fromMap({
        'restaurant_name': nameController.text,
        'about': descriptionController.text,
        'email': emailController.text,
        'restaurant_phone': phoneController.text,
        'location': locationController.text,
        'website':
            websiteController.text.isNotEmpty ? websiteController.text : null,
        'cuisine_type': selectedCuisine,
        'default_currency': selectedCurrency,
        'default_language': selectedLanguage,
        if (_logoImage != null)
          'logo': await MultipartFile.fromFile(_logoImage!.path),
        if (_bannerImage != null)
          'banner': await MultipartFile.fromFile(_bannerImage!.path),
      });

      context
          .read<RestaurantManagementBloc>()
          .add(UpdateRestaurantEvent(formData, selectedRestaurant.slug));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating restaurant: $e')),
      );
    }
  }

  Widget _buildSettingsItem({
    required String title,
    required IconData leadingIcon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(leadingIcon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
