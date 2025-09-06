import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/util/theme.dart';

class LoginTextfields extends StatefulWidget {
  final String labeltext;
  final String hintText;
  final bool isPassword;
  final bool isPhoneNumber;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText; // ✅ errorText supported

  const LoginTextfields({
    super.key,
    required this.labeltext,
    required this.hintText,
    this.isPassword = false,
    this.isPhoneNumber = false,
    this.keyboardType,
    this.inputFormatters,
    this.controller,
    this.onChanged,
    this.errorText,
  });

  @override
  State<LoginTextfields> createState() => _LoginTextfieldsState();
}

class _LoginTextfieldsState extends State<LoginTextfields> {
  bool _obscureText = true;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType = widget.keyboardType ??
        (widget.isPhoneNumber ? TextInputType.phone : TextInputType.text);

    List<TextInputFormatter> inputFormatters = widget.inputFormatters ??
        (widget.isPhoneNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : []);

    return TextFormField(
      controller: _controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labeltext,
        labelStyle: const TextStyle(
          color: AppColors.secondaryColor,
          fontFamily: 'Inter',
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: AppColors.secondaryColor,
          fontSize: 10,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.secondaryColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.secondaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorText: widget.errorText, // ✅ Now works
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        suffixIcon: _buildSuffixIcon(),
        prefix: widget.isPhoneNumber ? _buildPhonePrefix() : null,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.secondaryColor,
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
      );
    }
    return null;
  }

  Widget _buildPhonePrefix() {
    return const Padding(
      padding: EdgeInsets.only(right: 4.0),
      child: Text(
        '+251 ',
        style: TextStyle(
          color: AppColors.secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
