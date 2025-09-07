import '../../../../../core/util/theme.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String buttonname;
  final VoidCallback? onPressed;

  const LoginButton({super.key, required this.buttonname, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        fixedSize: const Size(300, 50),
      ),
      child: Text(
        buttonname,
        style: const TextStyle(
          color: AppColors.whiteColor,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
