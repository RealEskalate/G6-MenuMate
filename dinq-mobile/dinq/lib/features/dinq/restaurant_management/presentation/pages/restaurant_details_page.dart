import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RestaurantDetailsPage extends StatefulWidget {
  const RestaurantDetailsPage({super.key});

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;
  File? _bannerImage;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Restaurant Name', ''),
            const SizedBox(height: 16),
            _buildDropdownField('Cuisine Type', 'Ethiopian'),
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
            _buildTextField('Description', ''),
            const SizedBox(height: 16),
            _buildTextField('email', ''),
            const SizedBox(height: 16),
            _buildTextField('phone', ''),
            const SizedBox(height: 16),
            _buildTextField('Location', ''),
            const SizedBox(height: 16),
            _buildMapPreview(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 4, // Settings tab
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String initialValue) {
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
              value: initialValue,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Ethiopian', child: Text('Ethiopian')),
                DropdownMenuItem(value: 'Italian', child: Text('Italian')),
                DropdownMenuItem(value: 'Chinese', child: Text('Chinese')),
                DropdownMenuItem(value: 'Indian', child: Text('Indian')),
              ],
              onChanged: (value) {},
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
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          setState(() {
            if (isLogo) {
              _logoImage = File(pickedFile.path);
            } else {
              _bannerImage = File(pickedFile.path);
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
