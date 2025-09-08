import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:dinq/core/network/api_client.dart';
import 'package:dinq/core/network/api_endpoints.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:dinq/features/dinq/auth/data/repository/auth_repository_impl.dart';
import 'package:dinq/features/dinq/auth/domain/repository/Customer_reg_repo.dart';
import 'package:dinq/features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:dinq/features/dinq/auth/presentation/bloc/registration/registration_event.dart';
import 'package:dinq/features/dinq/auth/presentation/bloc/registration/registration_state.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/Register_page.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/forget_password_page.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_TextFields.dart';
import 'package:dinq/features/dinq/auth/presentation/widgets/Login_button.dart';
=======

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../widgets/Login_TextFields.dart';
import '../widgets/Login_button.dart';
import 'Register_page.dart';
import 'forget_password_page.dart';
>>>>>>> origin/mite-test

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

  // Controllers and error states
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  // BLoC instance
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();

    // Initialize BLoC
    _authBloc = _createAuthBloc();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Staggered animations
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _emailFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
      ),
    );

    _passwordFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
      ),
    );

    _forgotPasswordAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    _loginButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
      ),
    );

    _registerTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.75, curve: Curves.easeOut),
      ),
    );

    _dividerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.8, curve: Curves.easeOut),
      ),
    );

    _googleButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Create AuthBloc with your actual repository
  AuthBloc _createAuthBloc() {
    final apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);
    final AuthRepository authRepository = AuthRepositoryImpl(apiClient: apiClient);
    return AuthBloc(authRepository: authRepository);
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate email
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email address';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      isValid = false;
    } else {
      setState(() {
        _emailError = null;
      });
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Please enter your password';
      });
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      isValid = false;
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    return isValid;
  }

  void _handleLogin() {
    if (_validateForm()) {
<<<<<<< HEAD
      _authBloc.add(
        LoginUserEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
=======
      context.read<UserBloc>().add(
            LoginUserEvent(
              identifier: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
      Navigator.pushNamed(context, AppRoute.mainShell);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the validation errors'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
>>>>>>> origin/mite-test
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Navigate to home page or dashboard
            Navigator.pushReplacementNamed(context, '/explore');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
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
              // Animated Welcome Text
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _titleAnimation.value) * 20),
                    child: Opacity(
                      opacity: _titleAnimation.value,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Animated Email Field
              AnimatedBuilder(
                animation: _emailFieldAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset((1 - _emailFieldAnimation.value) * 50, 0),
                    child: Opacity(
                      opacity: _emailFieldAnimation.value,
                      child: LoginTextfields(
                        controller: _emailController,
                        labeltext: 'Email Address',
                        hintText: 'Enter your email',
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Animated Password Field
              AnimatedBuilder(
                animation: _passwordFieldAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset((1 - _passwordFieldAnimation.value) * 50, 0),
                    child: Opacity(
                      opacity: _passwordFieldAnimation.value,
                      child: LoginTextfields(
                        controller: _passwordController,
                        labeltext: 'Password',
                        hintText: '***********',
                        isPassword: true,
                        errorText: _passwordError,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              // Animated Forgot Password
              AnimatedBuilder(
                animation: _forgotPasswordAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _forgotPasswordAnimation.value,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ForgetPasswordPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forget Password?',
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 14,
                                fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              // Animated Login Button with GestureDetector
              AnimatedBuilder(
                animation: _loginButtonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.9 + (_loginButtonAnimation.value * 0.1),
                    child: Opacity(
                      opacity: _loginButtonAnimation.value,
                      child: Center(
<<<<<<< HEAD
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return state is AuthLoading
                                ? const CircularProgressIndicator()
                                : LoginButton(
                                    buttonname: "Login",
                                    onPressed: _handleLogin,
                                  );
                          },
=======
                        child: LoginButton(
                          buttonname: 'Login',
                          onPressed: _handleLogin,
>>>>>>> origin/mite-test
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              // Animated Register Text
              AnimatedBuilder(
                animation: _registerTextAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _registerTextAnimation.value,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
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
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const RegisterPage(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                ),
                              );
                            },
                            child: const Text(
                              'Register',
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
                  );
                },
              ),
              const SizedBox(height: 40),
              // Animated Divider
              AnimatedBuilder(
                animation: _dividerAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _dividerAnimation.value,
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
                            color: AppColors.secondaryColor.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Animated Google Button
              AnimatedBuilder(
                animation: _googleButtonAnimation,
                builder: (context, child) {
                  return Transform.translate(
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
                                'Sign in with Google',
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
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}
