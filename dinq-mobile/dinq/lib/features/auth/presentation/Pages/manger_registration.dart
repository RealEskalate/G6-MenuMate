import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/Login_TextFields.dart';
import '../widgets/Login_button.dart';
import '../widgets/checkbox.dart';

class ManagerRegistration extends StatefulWidget {
  const ManagerRegistration({super.key});

  @override
  State<ManagerRegistration> createState() => _ManagerRegistrationState();
}

class _ManagerRegistrationState extends State<ManagerRegistration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _usernameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isTermsAccepted = false;

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
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateAllFields() {
    setState(() {
      _usernameError = _validateUsername(_usernameController.text);
      _emailError = _validateEmail(_emailController.text);
      _phoneError = _validatePhone(_phoneController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError =
          _validateConfirmPassword(_confirmPasswordController.text);
    });

    return _usernameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _isTermsAccepted;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    if (value.length < 3) return 'Username must be at least 3 characters';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Only letters, numbers, and underscores allowed';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _registerManager() {
    if (_validateAllFields()) {
      context.read<UserBloc>().add(
            RegisterUserEvent(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              authProvider: 'EMAIL',
              // phone number was collected but RegisterUserEvent doesn't have phoneNumber field in this project's user_event
              // We'll pass phone as part of firstName temporarily if needed, or ignore for now.
              role: 'OWNER',
            ),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the validation errors and accept terms'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserRegistered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Manager registration successful! Please continue with restaurant setup.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          Navigator.pushNamed(context, AppRoute.restaurantRegister);
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
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
                    child: const Text(
                      'Create Manger Account',
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
                    child: const Text(
                      'Join Dineq to manage your restaurant efficiently',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Animated form fields with staggered delay
                AnimatedFormField(
                  animation: _fadeAnimation,
                  delay: 100,
                  child: LoginTextfields(
                    controller: _usernameController,
                    labeltext: 'Username',
                    hintText: 'Enter your Username',
                    errorText: _usernameError,
                    onChanged: (value) {
                      setState(() {
                        _usernameError = _validateUsername(value);
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),
                AnimatedFormField(
                  animation: _fadeAnimation,
                  delay: 200,
                  child: LoginTextfields(
                    controller: _emailController,
                    labeltext: 'Email Address',
                    hintText: "We'll use this to send you important updates",
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (value) {
                      setState(() {
                        _emailError = _validateEmail(value);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedFormField(
                  animation: _fadeAnimation,
                  delay: 300,
                  child: LoginTextfields(
                    controller: _phoneController,
                    labeltext: 'Phone Number',
                    hintText: 'Include country code (e.g., +251 for Ethiopia)',
                    isPhoneNumber: true,
                    errorText: _phoneError,
                    onChanged: (value) {
                      setState(() {
                        _phoneError = _validatePhone(value);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedFormField(
                  animation: _fadeAnimation,
                  delay: 400,
                  child: LoginTextfields(
                    controller: _passwordController,
                    labeltext: 'Password',
                    hintText:
                        'Must be at least 8 characters with uppercase, lowercase, and number',
                    isPassword: true,
                    errorText: _passwordError,
                    onChanged: (value) {
                      setState(() {
                        _passwordError = _validatePassword(value);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedFormField(
                  animation: _fadeAnimation,
                  delay: 500,
                  child: LoginTextfields(
                    controller: _confirmPasswordController,
                    labeltext: 'Confirm Password',
                    hintText: 'Re-enter your password to confirm',
                    isPassword: true,
                    errorText: _confirmPasswordError,
                    onChanged: (value) {
                      setState(() {
                        _confirmPasswordError = _validateConfirmPassword(value);
                      });
                    },
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
                          CustomCheckbox(
                            onChanged: (value) {
                              setState(() {
                                _isTermsAccepted = value;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service ',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'and ',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy *',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
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
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: state is UserLoading
                            ? const CircularProgressIndicator()
                            : LoginButton(
                                buttonname: 'Register',
                                onPressed: _registerManager,
                              ),
                      ),
                    );
                  },
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
                            color: AppColors.secondaryColor.withValues(alpha: 0.5),
                            thickness: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: AppColors.secondaryColor,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.secondaryColor.withValues(alpha: 0.5),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.g_mobiledata,
                              size: 24,
                              color: Colors.green,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Sign up with Google',
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
    super.key,
    required this.animation,
    required this.delay,
    required this.child,
  });

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
