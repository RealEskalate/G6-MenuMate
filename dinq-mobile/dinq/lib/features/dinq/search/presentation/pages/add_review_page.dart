import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/util/theme.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({super.key});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  int _rating = 0;
  final TextEditingController _controller = TextEditingController();
  final int _maxLength = 500;
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  bool get _canSubmit {
    return _rating > 0 || _controller.text.trim().length >= 10;
  }

  Future<void> _onPhotoUpload() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                    maxWidth: 800,
                    maxHeight: 800,
                  );
                  if (picked != null) {
                    setState(() {
                      _photos.add(File(picked.path));
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? picked = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                    maxWidth: 800,
                    maxHeight: 800,
                  );
                  if (picked != null) {
                    setState(() {
                      _photos.add(File(picked.path));
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: index < _rating ? AppColors.primaryColor : Colors.grey[300],
            size: 36,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
          splashRadius: 20,
          padding: EdgeInsets.zero,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Add Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          children: [
            const SizedBox(height: 8),
            const Text(
              'Rate your experience',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildStarRating(),
            const SizedBox(height: 4),
            Center(
              child: Text(
                _rating == 0
                    ? 'Tap to rate'
                    : 'You rated $_rating star${_rating > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Share your thoughts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 5,
              maxLength: _maxLength,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tell us about your experience...',
                hintStyle: TextStyle(color: Colors.grey[350]),
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: BorderSide(
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                counterText: '',
              ),
              style: const TextStyle(fontSize: 15),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Min. 10 characters',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${_controller.text.length}/$_maxLength',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Add photos (optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _onPhotoUpload,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade200,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey[50],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.grey[400],
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Upload photos',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'JPG, PNG up to 5MB each',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            if (_photos.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _photos[i],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _photos.removeAt(i);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 2),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canSubmit ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSubmit
                  ? AppColors.primaryColor
                  : Colors.grey[300],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            child: const Text('Submit Review'),
          ),
        ),
      ),
    );
  }
}
