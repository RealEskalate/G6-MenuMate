import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../../presentation/bloc/user_bloc.dart';
// registration bloc unused here; using global UserBloc instead
import '../widgets/choose_box.dart';
import 'manger_registration.dart';
import 'user_Register.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _box1Animation;
  late Animation<double> _box2Animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Title animation - fades in and slides from top
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Subtitle animation - fades in after title
    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    // First box animation - slides from left
    _box1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Second box animation - slides from right
    _box2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Use the globally provided UserBloc (registered in DI)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Animated title
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _titleAnimation.value) * 20),
                    child: Opacity(
                      opacity: _titleAnimation.value,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Who are you?',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Animated subtitle
              AnimatedBuilder(
                animation: _subtitleAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _subtitleAnimation.value) * 15),
                    child: Opacity(
                      opacity: _subtitleAnimation.value,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Choose your role to get the most out of MenuMate',
                              style: TextStyle(
                                color: AppColors.secondaryColor,
                                fontSize: 16,
                                fontFamily: 'Inter',
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
              // Animated Customer option
              AnimatedBuilder(
                animation: _box1Animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset((1 - _box1Animation.value) * -100, 0),
                    child: Opacity(
                      opacity: _box1Animation.value,
                      child: Transform.scale(
                        scale: 0.9 + (_box1Animation.value * 0.1),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        BlocProvider.value(
                                  value: BlocProvider.of<UserBloc>(context),
                                  child: const UserRegister(),
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: const ChooseBox(
                            category: 'Customer',
                            explanation:
                                'Discover dishes, scan QR menus and share reviews',
                            icon: Icons.person,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Animated Restaurant option
              AnimatedBuilder(
                animation: _box2Animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset((1 - _box2Animation.value) * 100, 0),
                    child: Opacity(
                      opacity: _box2Animation.value,
                      child: Transform.scale(
                        scale: 0.9 + (_box2Animation.value * 0.1),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const MangerRegistration(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: const ChooseBox(
                            category: 'Restaurant',
                            explanation:
                                'Create and manage digital menus, generate QR codes and track performance',
                            icon: Icons.restaurant,
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
    );
  }
}
