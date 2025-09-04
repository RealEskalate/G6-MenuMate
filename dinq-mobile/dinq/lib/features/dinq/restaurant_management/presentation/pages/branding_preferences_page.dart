import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BrandingPreferencesPage extends StatefulWidget {
  const BrandingPreferencesPage({Key? key}) : super(key: key);

  @override
  State<BrandingPreferencesPage> createState() => _BrandingPreferencesPageState();
}

class _BrandingPreferencesPageState extends State<BrandingPreferencesPage> {
  // Default values
  Color _primaryColor = const Color(0xFFFD7E14);
  Color _accentColor = const Color(0xFF999999);
  String _defaultCurrency = 'ETB';
  String _defaultLanguage = 'English';
  String _vatPercentage = '15%';
  
  // Text controllers to prevent automatic filling
  final TextEditingController _vatController = TextEditingController(text: '15%');
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _vatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
            const Text(
              'Branding',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildColorField('Primary color', _primaryColor, (color) {
              setState(() {
                _primaryColor = color;
              });
            }),
            const SizedBox(height: 16),
            _buildColorField('Accent color', _accentColor, (color) {
              setState(() {
                _accentColor = color;
              });
            }),
            const SizedBox(height: 24),
            const Text(
              'Menu preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDropdownField('Default currency', _defaultCurrency, ['ETB', 'USD', 'EUR', 'GBP']),
            const SizedBox(height: 16),
            _buildDropdownField('Default language', _defaultLanguage, ['English', 'Amharic', 'French', 'Arabic']),
            const SizedBox(height: 16),
            _buildTextField('Default VAT/Service Charge (%)', _vatPercentage, (value) {
              setState(() {
                _vatPercentage = value;
              });
            }, controller: _vatController),
          ],
        ),
      ),
      
    );
  }

  Widget _buildColorField(String label, Color color, Function(Color) onColorChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  _showColorPicker(color, onColorChanged);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showColorPicker(Color currentColor, Function(Color) onColorChanged) {
    Color pickerColor = currentColor;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onChanged: (newValue) {
                setState(() {
                  if (label == 'Default currency') {
                    _defaultCurrency = newValue!;
                  } else if (label == 'Default language') {
                    _defaultLanguage = newValue!;
                  }
                });
              },
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          controller: controller ?? TextEditingController(text: value),
          onChanged: onChanged,
        ),
      ],
    );
  }
}