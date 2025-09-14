import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routing/app_route.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
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
    context.read<AuthBloc>().add(CheckAuthEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('DEBUG: AuthGate listener state: $state');
        if (state is Authenticated) {
          // User is authenticated, navigate to main shell
          print('DEBUG: Authenticated, navigating to mainShell');
          Navigator.pushReplacementNamed(context, AppRoute.mainShell);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('DEBUG: AuthGate builder state: $state');
          if (state is AuthLoading) {
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
