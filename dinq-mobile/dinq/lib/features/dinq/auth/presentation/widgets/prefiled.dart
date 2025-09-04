import 'package:flutter/material.dart';
import 'package:dinq/core/util/theme.dart';

class CustomTextField extends StatefulWidget {
  final String initialText;
  final String labelText;
  final String hintText;
  final bool isPassword;
  final bool isPhoneNumber;
  final TextInputType? keyboardType;

  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.initialText ,
    required this.labelText,
    this.hintText="",
    this.isPassword = false,
    this.isPhoneNumber = false,
    this.keyboardType,
    this.onChanged,
    this.errorText,
    this.validator,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine keyboard type based on field type
    TextInputType keyboardType = widget.keyboardType ??
        (widget.isPhoneNumber ? TextInputType.phone : TextInputType.text);
    
    // Determine input formatters based on field type
    // List<TextInputFormatter> inputFormatters = widget.inputFormatters ??
    //     (widget.isPhoneNumber
    //         ? [FilteringTextInputFormatter.digitsOnly]
    //         : []);

    return TextFormField(
      controller: _controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: keyboardType,
      onChanged: widget.onChanged,
      validator: widget.validator,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: AppColors.secondaryColor,
          fontFamily: 'Inter'
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: AppColors.secondaryColor, fontSize: 10),
        border: OutlineInputBorder( 
          borderSide: BorderSide(color: AppColors.secondaryColor), 
          borderRadius: BorderRadius.circular(8.0)
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorText: widget.errorText,
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(
          color: const Color(0xFF374151),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        suffixIcon: _buildSuffixIcon(),
        prefix: widget.isPhoneNumber ? _buildPhonePrefix() : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDense: true,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.secondaryColor,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.isPhoneNumber) {
      return Icon(
        Icons.phone,
        color: AppColors.secondaryColor.withOpacity(0.7),
        size: 20,
      );
    }
    return null;
  }

  Widget _buildPhonePrefix() {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Text(
        '+251 ',
        style: TextStyle(
          color: AppColors.secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}