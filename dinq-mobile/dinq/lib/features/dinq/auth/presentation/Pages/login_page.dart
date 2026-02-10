import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/Register_page.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/forget_password_page.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_TextFields.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_button.dart';

import '../bloc/registration/registration_bloc.dart';
import '../bloc/registration/registration_event.dart';
import '../bloc/registration/registration_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _emailFieldAnimation;
  late Animation<double> _passwordFieldAnimation;
  late Animation<double> _forgotPasswordAnimation;
  late Animation<double> _loginButtonAnimation;
  late Animation<double> _registerTextAnimation;
  late Animation<double> _dividerAnimation;
  late Animation<double> _googleButtonAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.2, curve: Curves.easeOut)),
    );
    _emailFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.1, 0.4, curve: Curves.easeOut)),
    );
    _passwordFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.5, curve: Curves.easeOut)),
    );
    _forgotPasswordAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 0.6, curve: Curves.easeOut)),
    );
    _loginButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 0.7, curve: Curves.easeOut)),
    );
    _registerTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.6, 0.75, curve: Curves.easeOut)),
    );
    _dividerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.7, 0.8, curve: Curves.easeOut)),
    );
    _googleButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.8, 1.0, curve: Curves.easeOut)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;

    if (_emailController.text.isEmpty) {
      _emailError = 'Please enter your email address';
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      _emailError = 'Please enter a valid email address';
      isValid = false;
    } else {
      _emailError = null;
    }

    if (_passwordController.text.isEmpty) {
      _passwordError = 'Please enter your password';
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    } else {
      _passwordError = null;
    }

    setState(() {});
    return isValid;
  }

  void _handleLogin() {
    if (_validateForm()) {
      BlocProvider.of<AuthBloc>(context).add(LoginUserEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacementNamed(context, '/explore');
    }  else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _titleAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _titleAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - _titleAnimation.value) * 20),
                      child: const Text(
                        "Welcome back!",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Email Field
                AnimatedBuilder(
                  animation: _emailFieldAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _emailFieldAnimation.value,
                    child: Transform.translate(
                      offset: Offset((1 - _emailFieldAnimation.value) * 50, 0),
                      child: LoginTextfields(
                        controller: _emailController,
                        labeltext: "Email Address",
                        hintText: "Enter your email",
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Password Field
                AnimatedBuilder(
                  animation: _passwordFieldAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _passwordFieldAnimation.value,
                    child: Transform.translate(
                      offset:
                          Offset((1 - _passwordFieldAnimation.value) * 50, 0),
                      child: LoginTextfields(
                        controller: _passwordController,
                        labeltext: "Password",
                        hintText: "***********",
                        isPassword: true,
                        errorText: _passwordError,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Forgot password
                AnimatedBuilder(
                  animation: _forgotPasswordAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _forgotPasswordAnimation.value,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, a1, a2) =>
                              const ForgetPasswordPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) =>
                                  SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Forget Password?",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Login Button
                AnimatedBuilder(
                  animation: _loginButtonAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: 0.9 + (_loginButtonAnimation.value * 0.1),
                    child: Opacity(
                      opacity: _loginButtonAnimation.value,
                      child: Center(
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return state is AuthLoading
                                ? const CircularProgressIndicator()
                                : LoginButton(
                                    buttonname: "Login",
                                    onPressed: _handleLogin,
                                  );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Register Text
                AnimatedBuilder(
                  animation: _registerTextAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _registerTextAnimation.value,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: AppColors.secondaryColor,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a1, a2) =>
                                    const RegisterPage(),
                                transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                                transitionDuration:
                                    const Duration(milliseconds: 400),
                              ),
                            ),
                            child: Text(
                              "Register",
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
                ),
                const SizedBox(height: 40),
                // Divider
                AnimatedBuilder(
                  animation: _dividerAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _dividerAnimation.value,
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
                const SizedBox(height: 40),
                // Google Sign-In Button
                AnimatedBuilder(
                  animation: _googleButtonAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, (1 - _googleButtonAnimation.value) * 20),
                    child: Opacity(
                      opacity: _googleButtonAnimation.value,
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
                              Icon(Icons.g_mobiledata,
                                  size: 24, color: Colors.green),
                              const SizedBox(width: 12),
                              Text(
                                "Sign in with Google",
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
