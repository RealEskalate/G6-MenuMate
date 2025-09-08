import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/restaurant_event.dart';
import '../bloc/restaurant_state.dart';
import '../bloc/restaurant_bloc.dart';
import '../../data/model/restaurant_model.dart';


import '../../domain/entities/restaurant.dart';

class RestaurantDetailsPage extends StatefulWidget {
<<<<<<< HEAD
   const RestaurantDetailsPage({super.key});
=======
  final Restaurant restaurant;
  const RestaurantDetailsPage({super.key, required this.restaurant});
>>>>>>> origin/mite-test

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
   String selectedCuisine = 'Ethiopian';
   String logoPath = '';
   String bannerPath = '';

   @override
   void initState() {
     super.initState();
     nameController = TextEditingController();
     descriptionController = TextEditingController();
     emailController = TextEditingController();
     phoneController = TextEditingController();
     locationController = TextEditingController();
   }

   @override
   void dispose() {
     nameController.dispose();
     descriptionController.dispose();
     emailController.dispose();
     phoneController.dispose();
     locationController.dispose();
     super.dispose();
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
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Restaurant Name', nameController),
                    const SizedBox(height: 16),
                    _buildDropdownField('Cuisine Type'),
                    const SizedBox(height: 24),
                    const Text(
                      'Logo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildImageUpload(isLogo: true),
                    const SizedBox(height: 24),
                    const Text(
                      'Cover Banner',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildImageUpload(isWide: true, isLogo: false),
                    const SizedBox(height: 24),
                    _buildTextField('Description', descriptionController),
                    const SizedBox(height: 16),
                    _buildTextField('email', emailController),
                    const SizedBox(height: 16),
                    _buildTextField('phone', phoneController),
                    const SizedBox(height: 16),
                    _buildTextField('Location', locationController),
                    const SizedBox(height: 16),
                    _buildMapPreview(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final formData = {
                          'name': nameController.text,
                          'description': descriptionController.text,
                          'email': emailController.text,
                          'phone': phoneController.text,
                          'location': locationController.text,
                          'cuisine': selectedCuisine,
                          'logo': logoPath,
                          'banner': bannerPath,
                        };
                        context.read<RestaurantBloc>().add(UpdateRestaurantEvent(formData, 'the-italian-corner-dce19f8f'));
                      },
                      child: const Text('Update Restaurant'),
                    ),
                  ],
                ),
              ),
              if (state is RestaurantLoading)
                const Center(child: CircularProgressIndicator()),
              if (state is RestaurantError)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red,
                    child: Text('Error: ${state.message}'),
                  ),
                ),
              if (state is RestaurantActionSuccess)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.green,
                    child: Text(state.message),
                  ),
                ),
            ],
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
               value: selectedCuisine,
               isExpanded: true,
               items: const [
                 DropdownMenuItem(value: 'Ethiopian', child: Text('Ethiopian')),
                 DropdownMenuItem(value: 'Italian', child: Text('Italian')),
                 DropdownMenuItem(value: 'Chinese', child: Text('Chinese')),
                 DropdownMenuItem(value: 'Indian', child: Text('Indian')),
               ],
               onChanged: (value) => setState(() => selectedCuisine = value!),
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

  Widget _buildMapPreview() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 32, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text('Map Preview', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
