import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'features/dinq/auth/presentation/Pages/onboarding_first.dart';
import 'features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';
import 'injection_container.dart' as di;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  di.init();

  print('🚀 Starting comprehensive API diagnostics using Dio...');

  runTests().then((_) {
    print('\n🎉 All diagnostics completed!');
    runApp(const MyApp());
  }).catchError((error) {
    print('❌ Diagnostics failed: $error');
    runApp(const MyApp());
  });
}

Future<void> runTests() async {
  await testServerConnectivity();
  await testApiEndpoints();
}

Future<void> testServerConnectivity() async {
  final dio = Dio();
  print('🌐 Testing server connectivity with Dio...');

  try {
    final response = await dio.get('https://g6-menumate-1.onrender.com');
    print('✅ Server reachable - Status: ${response.statusCode}');
    print('Server response: ${response.data}');

    final apiResponse = await dio.get('https://g6-menumate-1.onrender.com/api/v1');
    print('✅ API root reachable - Status: ${apiResponse.statusCode}');
    print('API response: ${apiResponse.data}');
  } catch (e) {
    if (e is DioError) {
      print('❌ Dio connectivity error: ${e.message}');
    } else {
      print('❌ Unexpected error: $e');
    }
  }
}

Future<void> testApiEndpoints() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://g6-menumate-1.onrender.com/api/v1'));
  final endpoints = [
    '/auth/verify-email',
    '/auth/resend-otp',
    '/auth/verify-otp',
    '/auth/register',
    '/auth/login',
  ];

  print('🔍 Testing API endpoints...');
  for (var endpoint in endpoints) {
    try {
      final response = await dio.post(endpoint);
      print('✅ GET $endpoint - Status: ${response.statusCode}');
      print('Response: ${response.data}');
    } on DioError catch (e) {
      if (e.response != null) {
        print('⚠️ GET $endpoint - Status: ${e.response?.statusCode}, Data: ${e.response?.data}');
      } else {
        print('❌ GET $endpoint - Error: ${e.message}');
      }
    } catch (e) {
      print('❌ GET $endpoint - Unexpected error: $e');
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const OnboardingFirst(),
      ),
    );
  }
}