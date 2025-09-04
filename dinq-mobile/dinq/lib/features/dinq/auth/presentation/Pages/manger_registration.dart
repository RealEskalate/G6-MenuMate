import 'package:flutter/material.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/resturant_registration.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_TextFields.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_button.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/checkbox.dart';

class MangerRegistration extends StatefulWidget {
  const MangerRegistration({super.key});

  @override
  State<MangerRegistration> createState() => _MangerRegistrationState();
}

class _MangerRegistrationState extends State<MangerRegistration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Animated title
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    "Create Manger Account",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Animated subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    "Join Dineq to manage your restaurant efficiently",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Animated form fields with staggered delay
              AnimatedFormField(
                animation: _fadeAnimation,
                delay: 100,
                child: LoginTextfields(
                  labeltext: "Username",
                  hintText: "Enter your Username",
                ),
              ),

              const SizedBox(height: 20),
              AnimatedFormField(
                animation: _fadeAnimation,
                delay: 200,
                child: LoginTextfields(
                  labeltext: "Email Address",
                  hintText: "We'll use this to send you important updates",
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedFormField(
                animation: _fadeAnimation,
                delay: 300,
                child: LoginTextfields(
                  labeltext: "Phone Number",
                  hintText: "Include country code (e.g., +251 for Ethiopia)",
                  isPhoneNumber: true,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedFormField(
                animation: _fadeAnimation,
                delay: 400,
                child: LoginTextfields(
                  labeltext: "Password",
                  hintText: "Must be at least 8 characters with uppercase, lowercase, and number",
                  isPassword: true,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedFormField(
                animation: _fadeAnimation,
                delay: 500,
                child: LoginTextfields(
                  labeltext: "Confirm Password",
                  hintText: "Re-enter your password to confirm",
                  isPassword: true,
                ),
              ),
              const SizedBox(height: 20),
              // Animated checkbox
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCheckbox(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "I agree to the ",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: "Terms of Service ",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: "and ",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: "Privacy Policy *",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Animated button with scale effect
              ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const ResturantRegistration(),
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
                  },
                  child: LoginButton(buttonname: "Create Account")),
              ),
              const SizedBox(height: 30),
              // Animated "or" divider
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.secondaryColor.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "or",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondaryColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.secondaryColor.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Animated Google sign-in button
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.g_mobiledata,
                            size: 24,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Sign up with Google",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Extra padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget for staggered animation of form fields
class AnimatedFormField extends StatelessWidget {
  final Animation<double> animation;
  final int delay;
  final Widget child;

  const AnimatedFormField({
    Key? key,
    required this.animation,
    required this.delay,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value > (delay / 1000) ? 1.0 : 0.0,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}