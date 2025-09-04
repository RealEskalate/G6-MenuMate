// main.dart - CORRECTED
import 'package:dinq/features/dinq/auth/presentation/Pages/email_verfiction.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/verify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:dinq/core/network/api_client.dart';
import 'package:dinq/core/network/api_endpoints.dart';
import 'package:dinq/core/network/api_exceptions.dart';

import 'package:dinq/features/dinq/auth/data/repository/auth_repository_impl.dart';
import 'package:dinq/features/dinq/auth/domain/repository/Customer_reg_repo.dart';

import 'package:dinq/features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:dinq/features/dinq/auth/presentation/pages/onboarding_first.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
         create: (context) => AuthBloc(
           authRepository: AuthRepositoryImpl(
             apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
           ),
         ),
       ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const OnboardingFirst(),
      ),
    );
  }
}
