import 'package:flutter/material.dart';

import '../../../../../core/util/theme.dart';
import '../widgets/Login_TextFields.dart';
import '../widgets/Login_button.dart';
import 'email_verfiction.dart';
import 'login_page.dart';

// Add this import for the EmailVerification class


class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _textFieldAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _backButtonAnimation;

  // Add TextEditingController to capture the email input
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Staggered animations
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _textFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOut),
      ),
    );

    _backButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _navigateToEmailVerification() {
    final email = _emailController.text.trim();

    // Basic email validation
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EmailVerification(email: email),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Animated Title
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _titleAnimation.value) * 20),
                    child: Opacity(
                      opacity: _titleAnimation.value,
                      child: const Text(
                        'Forget Password',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Animated Subtitle
              AnimatedBuilder(
                animation: _subtitleAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _subtitleAnimation.value) * 15),
                    child: Opacity(
                      opacity: _subtitleAnimation.value,
                      child: const Text(
                        "Enter your email address and we'll send you a link to reset your password",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Animated TextField with controller
              AnimatedBuilder(
                animation: _textFieldAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset((1 - _textFieldAnimation.value) * 50, 0),
                    child: Opacity(
                      opacity: _textFieldAnimation.value,
                      child: LoginTextfields(
                        labeltext: 'Email Address',
                        hintText: 'Enter your email.',
                        controller: _emailController, // Pass the controller
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Animated Button with GestureDetector
              AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.9 + (_buttonAnimation.value * 0.1),
                    child: Opacity(
                      opacity: _buttonAnimation.value,
                      child: Center(
                        child: GestureDetector(
                          onTap: _navigateToEmailVerification,
                          child: const LoginButton(buttonname: 'Send Reset Link'),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Animated Back Button
              AnimatedBuilder(
                animation: _backButtonAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _backButtonAnimation.value,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(-1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.primaryColor,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Back to Sign in',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}