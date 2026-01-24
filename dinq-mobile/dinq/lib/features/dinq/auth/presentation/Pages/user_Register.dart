import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dinq/core/network/api_client.dart';
import 'package:dinq/core/network/api_endpoints.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:dinq/features/dinq/auth/data/repository/auth_repository_impl.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/login_page.dart';
import 'package:dinq/features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:dinq/features/dinq/auth/presentation/bloc/registration/registration_event.dart';
import 'package:dinq/features/dinq/auth/presentation/bloc/registration/registration_state.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_TextFields.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_button.dart';
import 'package:dinq/features/dinq/auth/domain/repository/customer_reg_repo.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateAllFields() {
    setState(() {
      _usernameError = _validateUsername(_usernameController.text);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(
        _confirmPasswordController.text,
      );
    });

    return _usernameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    if (value.length < 3) return 'Username must be at least 3 characters';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value))
      return 'Only letters, numbers, and underscores allowed';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _registerUser() {
    if (_validateAllFields()) {
      print('Attempting to register user with:');
      print('Username: ${_usernameController.text}');
      print('Email: ${_emailController.text}');
      context.read<AuthBloc>().add(
        RegisterUserEvent(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          authProvider: 'EMAIL',
          role: 'CUSTOMER', // Explicitly set role for customer registration
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the validation errors'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('AuthBloc state changed: $state');

        if (state is AuthRegistered) {
          print('Registration successful for user: ${state.user.username}');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful! Please login to continue.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          Future.delayed(const Duration(seconds: 3), () {
            print('Navigating to Login page');
            _navigateToLoginPage();
          });
        } else if (state is AuthError) {
          print('Authentication error: ${state.message}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is AuthLoading) {
          print('Registration in progress...');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: const Text(
                      "Create account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        fontFamily: 'Roboto',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedTextField(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
                  ),
                  child: LoginTextfields(
                    controller: _usernameController,
                    labeltext: "Username",
                    hintText: "Enter your username",
                    errorText: _usernameError,
                    onChanged: (value) {
                      setState(() {
                        _usernameError = _validateUsername(value);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedTextField(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.45, 0.75, curve: Curves.easeInOut),
                  ),
                  child: LoginTextfields(
                    controller: _emailController,
                    labeltext: "Email",
                    hintText: "Enter your email",
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
                AnimatedTextField(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
                  ),
                  child: LoginTextfields(
                    controller: _passwordController,
                    labeltext: "Password",
                    hintText: "*********",
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
                AnimatedTextField(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.55, 0.85, curve: Curves.easeInOut),
                  ),
                  child: LoginTextfields(
                    controller: _confirmPasswordController,
                    labeltext: "Confirm Password",
                    hintText: "*********",
                    isPassword: true,
                    errorText: _confirmPasswordError,
                    onChanged: (value) {
                      setState(() {
                        _confirmPasswordError = _validateConfirmPassword(value);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: state is AuthLoading
                            ? const CircularProgressIndicator()
                            : LoginButton(
                                buttonname: "Register",
                                onPressed: _registerUser,
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.secondaryColor.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "or",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondaryColor,
                            fontFamily: 'Roboto',
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
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
                    ),
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
                          children: const [
                            Icon(
                              Icons.g_mobiledata,
                              size: 24,
                              color: Colors.green,
                            ),
                            SizedBox(width: 12),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom widget for animating text fields
class AnimatedTextField extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AnimatedTextField({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
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
