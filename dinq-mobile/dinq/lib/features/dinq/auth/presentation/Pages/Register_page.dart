import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

<<<<<<< HEAD
import 'resturant_registration.dart';

class RegisterPage extends StatefulWidget {
=======
import '../../../../../core/util/theme.dart';
import '../../../../../injection_container.dart' as di;
import '../bloc/user_bloc.dart';
import '../widgets/choose_box.dart';
import 'manger_registration.dart';
import 'user_Register.dart';

class RegisterPage extends StatelessWidget {
>>>>>>> origin/mite-test
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _createAuthBloc(),
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Row(
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
              const SizedBox(height: 16),
              const Row(
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
              const SizedBox(height: 40),
<<<<<<< HEAD
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
                            final authBloc = context.read<AuthBloc>();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => BlocProvider.value(
                                  value: authBloc,
                                  child: const UserRegister(),
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: ChooseBox(
                            category: "Customer",
                            explanation: "Discover dishes, scan QR menus and share reviews",
                            icon: Icons.person,
                          ),
                        ),
=======
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          BlocProvider.value(
                        value: di.sl<UserBloc>(),
                        child: const UserRegister(),
>>>>>>> origin/mite-test
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 500),
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
              const SizedBox(height: 24),
<<<<<<< HEAD
              // Animated Restaurant option
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
                            final authBloc = context.read<AuthBloc>();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => BlocProvider.value(
                                  value: authBloc,
                                  child: const MangerRegistration(),
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: const ChooseBox(
                            category: "Resturant",
                            explanation: "Create and manage digital menus, generate QR codes and track performance",
                            icon: Icons.restaurant,
                          ),
                        ),
                      ),
=======
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const MangerRegistration(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 500),
>>>>>>> origin/mite-test
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
