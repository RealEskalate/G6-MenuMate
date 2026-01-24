import 'dart:io';

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../core/routing/app_route.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/constants.dart';
import '../../data/datasources/qr_code_remote_data_source.dart';
import '../../data/repositories/qr_code_repository_impl.dart';
import '../../domain/usecases/qr_code/generate_qr_code.dart';
import 'generated_qr_page.dart';

class QrCustomizationPage extends StatefulWidget {
  final String? menuId;
  final String? restaurantSlug;

  const QrCustomizationPage({
    Key? key,
    this.menuId,
    this.restaurantSlug,
  }) : super(key: key);

  @override
  State<QrCustomizationPage> createState() => _QrCustomizationPageState();
}

class _QrCustomizationPageState extends State<QrCustomizationPage> {
  bool _loading = false;

  // Color fields
  final _bgController = TextEditingController(text: '#ffffff');
  final _fgController = TextEditingController(text: '#000000');
  final _gradientFromController = TextEditingController(text: '#6366f1');
  final _gradientToController = TextEditingController(text: '#8b5cf6');
  final _labelColorController = TextEditingController(text: '#374151');

  String _gradientDirection = 'Top to Bottom';

  Color _bgColor = const Color(0xffffffff);
  Color _fgColor = const Color(0xff000000);
  Color _gradientFromColor = const Color(0xff6366f1);
  Color _gradientToColor = const Color(0xff8b5cf6);
  Color _labelColor = const Color(0xff374151);

  // Logo
  File? _logoFile;
  double _logoSize = 20; // percentage of QR size

  // Layout
  double _margin = 4;

  // Dummy QR data
  final String dummyData = "https://example.com";

  // Label
  final _labelController = TextEditingController();
  double _fontSize = 12;

  // Future<String?> _sendCustomizationAndGetQr() async {
  //   try {
  //     // Check if we have the required parameters
  //     if (widget.menuId == null || widget.restaurantSlug == null) {
  //       print('❌ Missing menuId or restaurantSlug');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Missing menu or restaurant information')),
  //       );
  //       return null;
  //     }

  //     // Prepare customization data
  //     final customizationData = {
  //       'background_color': _bgController.text,
  //       'foreground_color': _fgController.text,
  //       'gradient_from_color': _gradientFromController.text,
  //       'gradient_to_color': _gradientToController.text,
  //       'gradient_direction': _gradientDirection.toLowerCase().replaceAll(' ', '_'),
  //       'label_text': _labelController.text,
  //       'label_color': _labelColorController.text,
  //       'label_font_size': _fontSize,
  //       'logo_size_percentage': _logoSize,
  //       'margin': _margin,
  //       'has_logo': _logoFile != null,
  //     };

  //     print('🎨 Sending customization data: $customizationData');

  //     // Initialize API client and services
  //     final apiClient = ApiClient(baseUrl: baseUrl);
  //     final qrDataSource = QrCodeRemoteDataSourceImpl(apiClient: apiClient);
  //     final qrRepository = QrCodeRepositoryImpl(remoteDataSource: qrDataSource);
  //     final generateQrCode = GenerateQrCode(qrRepository);

  //     // Call the API
  //     final result = await generateQrCode(
  //       restaurantSlug: widget.restaurantSlug!,
  //       menuId: widget.menuId!,
  //       customizationData: customizationData,
  //     );

  //     return result.fold(
  //       (failure) {
  //         print('❌ QR generation failed: ${failure.message}');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Failed to generate QR code: ${failure.message}')),
  //         );
  //         return null;
  //       },
  //       (response) {
  //         print('✅ QR generation successful: $response');

  //         // Extract the QR code image URL from the response
  //         final qrData = response['data']?['qr_code'];
  //         if (qrData != null && qrData['image_url'] != null) {
  //           return qrData['image_url'] as String;
  //         } else {
  //           print('❌ No image URL in response');
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('No QR code image received from server')),
  //           );
  //           return null;
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     print('❌ QR generation error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error generating QR code: $e')),
  //     );
  //     return null;
  //   }
  // }
  Future<String?> _sendCustomizationAndGetQr() async {
  try {
    if (widget.menuId == null || widget.restaurantSlug == null) {
      print('❌ Missing menuId or restaurantSlug');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing menu or restaurant information')),
      );
      return null;
    }

    // Build the body in the structure the backend expects
    final body = {
      'format': "png",
      "size": 600,
      "quality": 92,
      "include_label": true,
      "customization": {
        "background_color": _bgController.text,
        "foreground_color": _fgController.text,
        "gradient_from": _gradientFromController.text,
        "gradient_to": _gradientToController.text,
        "gradient_direction":
            _gradientDirection.toLowerCase().replaceAll(' ', '_'),
        // ⚠️ Use an uploaded logo URL here if you have one
        "logo": _logoFile != null
            ? "https://res.cloudinary.com/dmahwet/image/upload/v1757007077/dineQ/general/huafbulre2yxgkxi0flu.png"
            : null,
        "logo_size_percent": _logoSize / 100, // backend expects 0.xx not %
        "margin": _margin.toInt(),
        "label_text": _labelController.text,
        "label_color": _labelColorController.text,
        "label_font_size": _fontSize.toInt(),
        "label_font_url":
            "https://github.com/google/fonts/raw/main/apache/opensans/OpenSans-SemiBold.ttf"
      }
    };

    print('📤 Sending request body: $body');

    // Initialize API client and services
    final apiClient = ApiClient(baseUrl: baseUrl);
    final qrDataSource = QrCodeRemoteDataSourceImpl(apiClient: apiClient);
    final qrRepository = QrCodeRepositoryImpl(remoteDataSource: qrDataSource);
    final generateQrCode = GenerateQrCode(qrRepository);

    // Call the API
    final result = await generateQrCode(
      restaurantSlug: widget.restaurantSlug!,
      menuId: widget.menuId!,
      customizationData: body,
    );

    return result.fold(
      (failure) {
        print('❌ QR generation failed: ${failure.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate QR code: ${failure.message}')),
        );
        return null;
      },
      (response) {
        print('✅ QR generation successful: $response');
        final qrData = response['data']?['qr_code'];
        if (qrData != null && qrData['image_url'] != null) {
          return qrData['image_url'] as String;
        } else {
          print('❌ No image URL in response');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No QR code image received from server')),
          );
          return null;
        }
      },
    );
  } catch (e) {
    print('❌ QR generation error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating QR code: $e')),
    );
    return null;
  }
}

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _logoFile = File(picked.path);
      });
    }
  }

  void _pickColor(Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (c) => tempColor = c,
              enableAlpha: false,
              displayThumbColor: true,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(tempColor);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  /// Build QR modules (transparent background so ShaderMask works)
  Widget _buildQrModules(double size, Color moduleColor) {
    return QrImageView(
      data: dummyData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.transparent,
      foregroundColor: moduleColor,
      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square),
      dataModuleStyle:
          const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square),
    );
  }

  /// Build QR preview (gradient overrides fg color)
  Widget _buildQrPreview({double size = 200}) {
    final useGradient = _gradientFromColor != _gradientToColor;

    // Logo size in pixels
    final logoPx = size * (_logoSize / 100.0);

    final qrModules = useGradient
        ? ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              colors: [_gradientFromColor, _gradientToColor],
              begin: _gradientDirection == 'Top to Bottom'
                  ? Alignment.topCenter
                  : Alignment.centerLeft,
              end: _gradientDirection == 'Top to Bottom'
                  ? Alignment.bottomCenter
                  : Alignment.centerRight,
            ).createShader(rect),
            blendMode: BlendMode.srcIn,
            child: _buildQrModules(size, Colors.black),
          )
        : _buildQrModules(size, _fgColor);

    return Container(
      padding: EdgeInsets.all(_margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background color
          Container(
            width: size,
            height: size,
            color: _bgColor,
          ),
          // QR modules
          qrModules,
          // Logo overlay
          if (_logoFile != null)
            SizedBox(
              width: logoPx,
              height: logoPx,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_logoFile!, fit: BoxFit.cover),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const qrSize = 200.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Menu QR'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Text('Preview',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),

            /// ✅ Live Preview
            Column(
              children: [
                _buildQrPreview(size: qrSize),
                if (_labelController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _labelController.text,
                      style: TextStyle(
                        color: _labelColor,
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Arial",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            // Colors
            _SectionCard(
              title: 'Colors',
              child: Column(
                children: [
                  _ColorPickerField(
                    label: "Background",
                    color: _bgColor,
                    controller: _bgController,
                    onPick: (c) {
                      setState(() {
                        _bgColor = c;
                        _bgController.text =
                            '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      });
                    },
                    pickColor: _pickColor,
                  ),
                  const SizedBox(height: 8),
                  _ColorPickerField(
                    label: "Foreground",
                    color: _fgColor,
                    controller: _fgController,
                    onPick: (c) {
                      setState(() {
                        _fgColor = c;
                        _fgController.text =
                            '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      });
                    },
                    pickColor: _pickColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Gradient
            _SectionCard(
              title: 'Gradient (overrides foreground if different)',
              child: Column(
                children: [
                  _ColorPickerField(
                    label: "From",
                    color: _gradientFromColor,
                    controller: _gradientFromController,
                    onPick: (c) {
                      setState(() {
                        _gradientFromColor = c;
                        _gradientFromController.text =
                            '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      });
                    },
                    pickColor: _pickColor,
                  ),
                  const SizedBox(height: 8),
                  _ColorPickerField(
                    label: "To",
                    color: _gradientToColor,
                    controller: _gradientToController,
                    onPick: (c) {
                      setState(() {
                        _gradientToColor = c;
                        _gradientToController.text =
                            '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      });
                    },
                    pickColor: _pickColor,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Direction'),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _gradientDirection,
                        items: const [
                          DropdownMenuItem(
                            value: 'Top to Bottom',
                            child: Text('Top to Bottom'),
                          ),
                          DropdownMenuItem(
                            value: 'Left to Right',
                            child: Text('Left to Right'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _gradientDirection = val);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Logo
            _SectionCard(
              title: 'Logo',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickLogo,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.orange, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: _logoFile == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          color: Colors.orange, size: 32),
                                      SizedBox(height: 4),
                                      Text('Tap to pick logo',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.orange)),
                                    ],
                                  )
                                : Center(
                                    child: Image.file(_logoFile!, height: 48),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Size (%)'),
                      Expanded(
                        child: Slider(
                          value: _logoSize,
                          min: 10,
                          max: 50,
                          divisions: 40,
                          label: '${_logoSize.round()}%',
                          activeColor: Colors.orange,
                          onChanged: (v) => setState(() => _logoSize = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${_logoSize.round()}%'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Layout
            _SectionCard(
              title: 'Layout',
              child: Row(
                children: [
                  const Text('Margin'),
                  Expanded(
                    child: Slider(
                      value: _margin,
                      min: 0,
                      max: 20,
                      divisions: 20,
                      label: '${_margin.round()}px',
                      activeColor: Colors.orange,
                      onChanged: (v) => setState(() => _margin = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${_margin.round()}px'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Label
            _SectionCard(
              title: 'Label',
              child: Column(
                children: [
                  TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Text',
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  _ColorPickerField(
                    label: "Color",
                    color: _labelColor,
                    controller: _labelColorController,
                    onPick: (c) {
                      setState(() {
                        _labelColor = c;
                        _labelColorController.text =
                            '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      });
                    },
                    pickColor: _pickColor,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Font Size'),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 8,
                          max: 32,
                          divisions: 24,
                          label: '${_fontSize.round()}px',
                          activeColor: Colors.orange,
                          onChanged: (v) => setState(() => _fontSize = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${_fontSize.round()}px'),
                    ],
                  ),
                  // ✅ Font family input removed (default Arial used)
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _bgController.text = '#ffffff';
                        _fgController.text = '#000000';
                        _gradientFromController.text = '#6366f1';
                        _gradientToController.text = '#8b5cf6';
                        _gradientDirection = 'Top to Bottom';
                        _logoFile = null;
                        _logoSize = 20;
                        _margin = 4;
                        _labelController.clear();
                        _labelColorController.text = '#374151';
                        _fontSize = 12;

                        _bgColor = const Color(0xffffffff);
                        _fgColor = const Color(0xff000000);
                        _gradientFromColor = const Color(0xff6366f1);
                        _gradientToColor = const Color(0xff8b5cf6);
                        _labelColor = const Color(0xff374151);
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            final qrPath = await _sendCustomizationAndGetQr();
                            setState(() => _loading = false);
                            if (qrPath != null && mounted) {
                              // Navigate to generated QR page with the image URL
                              Navigator.of(context).pushNamed(
                                AppRoute.generatedQr,
                                arguments: {
                                  'qrImagePath': qrPath,
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to generate QR code.'),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Generate QR'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Reusable color picker + hex field
class _ColorPickerField extends StatelessWidget {
  final String label;
  final Color color;
  final TextEditingController controller;
  final ValueChanged<Color> onPick;
  final void Function(Color, ValueChanged<Color>) pickColor;

  const _ColorPickerField({
    required this.label,
    required this.color,
    required this.controller,
    required this.onPick,
    required this.pickColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        GestureDetector(
          onTap: () => pickColor(color, onPick),
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        SizedBox(
          width: 90,
          child: TextField(
            controller: controller,
            onChanged: (val) {
              if (val.startsWith('#') && val.length == 7) {
                onPick(Color(int.parse('ff${val.substring(1)}', radix: 16)));
              }
            },
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconForTitle(title), size: 18, color: Colors.orange),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Colors':
        return Icons.color_lens;
      case 'Gradient':
        return Icons.gradient;
      case 'Logo':
        return Icons.image;
      case 'Layout':
        return Icons.crop_square;
      case 'Label':
        return Icons.text_fields;
      default:
        return Icons.settings;
    }
  }
}
