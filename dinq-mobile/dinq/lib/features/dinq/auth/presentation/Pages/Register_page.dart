import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../../../../../injection_container.dart' as di;
import '../bloc/user_bloc.dart';
import '../widgets/choose_box.dart';
import 'manger_registration.dart';
import 'user_Register.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.sl<UserBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Who are you?',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose your role to get the most out of MenuMate',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 40),

                // Customer option
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: di.sl<UserBloc>(),
                          child: const UserRegister(),
                        ),
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

                // Restaurant / Manager option
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MangerRegistration(),
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
