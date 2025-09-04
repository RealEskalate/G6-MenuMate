import 'package:flutter/material.dart';
import 'package:dinq/core/util/theme.dart';

class CustomCheckbox extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const CustomCheckbox({super.key, this.onChanged});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _isChecked,
      onChanged: (bool? value) {
        setState(() {
          _isChecked = value ?? false;
        });
        widget.onChanged?.call(_isChecked);
      },
      activeColor: AppColors.secondaryColor, // Color when checked
      checkColor: AppColors.primaryColor, // Color of the check icon
      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey; // Color when disabled
        }
        return AppColors.whiteColor; // Use the default activeColor
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // Rounded corners
      ),
    );
  }
}