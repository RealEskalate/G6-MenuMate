import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../customer_shell.dart';
import '../../features/dinq/auth/presentation/Pages/login_page.dart';
import '../../features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';
import '../../features/dinq/auth/presentation/bloc/registration/registration_state.dart';
import '../../owner_shell.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {

        // 🔹 User is logged in
        if (state is AuthLoggedIn ) {
          final user = state.user;

          if (user.role == 'CUSTOMER') {
            return const CustomerShell();
          } else {
            return const OwnerShell();
          }
        }

        // 🔹 User explicitly logged out
        if (state is AuthLoggedOut) {
          return const LoginPage();
        }

        // 🔹 Initial / Loading states
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔹 Default fallback
        return const LoginPage();
      },
    );
  }
}

