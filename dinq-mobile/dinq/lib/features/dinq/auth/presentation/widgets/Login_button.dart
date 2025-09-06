import '../../../../../core/util/theme.dart';
import 'package:flutter/material.dart';


class LoginButton extends StatelessWidget {
  final buttonname;
  const LoginButton({super.key,required this.buttonname});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        fixedSize: const Size(300, 50)),
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
