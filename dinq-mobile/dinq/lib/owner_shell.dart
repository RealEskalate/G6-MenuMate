import 'package:flutter/material.dart';

import 'features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';
import 'features/dinq/auth/presentation/bloc/registration/registration_state.dart';
import 'features/dinq/restaurant_management/presentation/widgets/owner_navbar.dart';
import 'features/dinq/search/presentation/pages/home_page.dart';

class OwnerShell extends StatelessWidget {
  const OwnerShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final restaurantId =
        (state is AuthLoggedIn) ? state.user.restaurantId : null;

    return Scaffold(
      body: const HomePage(), // shared content
      bottomNavigationBar: OwnerNavBar(
        currentIndex: 0,
        restaurantId: restaurantId,
      ),
    );
  }
}