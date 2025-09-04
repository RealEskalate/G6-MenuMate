import 'package:flutter/material.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_TextFields.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_button.dart';

class RestPassword extends StatelessWidget {
  const RestPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        padding: EdgeInsets.all(16), // Add padding for better spacing
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40), // Reduced from 60
              Text("Reset Password",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black
                ),
              ),
              const SizedBox(height: 8),
              Text("Enter your email and new password to reset",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30), // Reduced from 40
              LoginTextfields(labeltext: "Email", hintText: "Enter your Email"),
              const SizedBox(height: 16), // Reduced from 20
              LoginTextfields(labeltext: "New Password", hintText: "Enter 8 character new password", isPassword: true),
              const SizedBox(height: 16), // Reduced from 20
              LoginTextfields(labeltext: "Confirm New Password", hintText: "Confirm new password", isPassword: true),
              const SizedBox(height: 30), // Reduced from 40
              LoginButton(buttonname: "Reset Password"), // Changed button text to be more descriptive
              const SizedBox(height: 20), // Added extra space at bottom for scrolling
            ],
          ),
        ),
      ),
    );
  }
}