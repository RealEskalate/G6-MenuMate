import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routing/app_route.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import 'onboarding_first.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Check authentication status
    context.read<UserBloc>().add(CheckAuthEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is AuthChecked) {
          if (state.user != null) {
            // User is authenticated, navigate to main shell
            Navigator.pushReplacementNamed(context, AppRoute.mainShell);
          }
          // If user is null, stay on onboarding (handled by builder)
        } else if (state is UserLoggedIn || state is UserRegistered) {
          // User just logged in/registered, navigate to main shell
          Navigator.pushReplacementNamed(context, AppRoute.mainShell);
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            // Show loading screen while checking auth
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Default to onboarding if not authenticated
          return const OnboardingFirst();
        },
      ),
    );
  }
}
