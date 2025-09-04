// main.dart - CORRECTED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:dinq/core/network/api_client.dart';
import 'package:dinq/core/network/api_endpoints.dart';
import 'package:dinq/core/network/api_exceptions.dart';

import 'package:dinq/features/dinq/auth/data/repository/auth_repository_impl.dart';

import 'package:dinq/features/dinq/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:dinq/features/dinq/auth/presentation/pages/onboarding_first.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting comprehensive API diagnostics...');

  // Run tests in sequence using async/await
  runTests().then((_) {
    print('\n🎉 All diagnostics completed!');
    runApp(const MyApp());
  }).catchError((error) {
    print('❌ Diagnostics failed: $error');
    runApp(const MyApp());
  });
}

// New async function to run all tests
Future<void> runTests() async {
  await testServerConnectivity();
  await testWithBasicHttp();
  await debugApiEndpoints();
}

Future<void> testServerConnectivity() async {
  final client = http.Client();

  print('🌐 Testing server connectivity...');

  try {
    // Test basic connectivity
    final response = await client.get(Uri.parse('https://g6-menumate.onrender.com'));
    print('✅ Server is reachable - Status: ${response.statusCode}');

    // Test API root
    final apiResponse = await client.get(Uri.parse('https://g6-menumate.onrender.com/api/v1'));
    print('✅ API root - Status: ${apiResponse.statusCode}');

    // Print response bodies for clues
    print('Server response: ${response.body}');
    print('API response: ${apiResponse.body}');

  } catch (e) {
    print('❌ Server connectivity failed: $e');
  } finally {
    client.close();
  }
}

Future<void> testWithBasicHttp() async {
  print('🔧 Testing with basic http client...');

  try {
    // Test 1: Simple GET to base URL
    var response = await http.get(Uri.parse('https://g6-menumate.onrender.com'));
    print('Base URL - Status: ${response.statusCode}, Body: ${response.body}');

    // Test 2: API v1
    response = await http.get(Uri.parse('https://g6-menumate.onrender.com/api/v1'));
    print('API v1 - Status: ${response.statusCode}, Body: ${response.body}');

    // Test 3: Auth endpoint
    response = await http.get(Uri.parse('https://g6-menumate.onrender.com/api/v1/auth'));
    print('Auth - Status: ${response.statusCode}, Body: ${response.body}');

    // Test 4: Specific register endpoint
    response = await http.get(Uri.parse('https://g6-menumate.onrender.com/api/v1/auth/register'));
    print('Register - Status: ${response.statusCode}, Body: ${response.body}');

  } catch (e) {
    print('❌ Basic http test failed: $e');
  }
}

Future<void> debugApiEndpoints() async {
  final apiClient = ApiClient(baseUrl: 'https://g6-menumate-1.onrender.com/api/v1');

  print('🔍 Debugging API endpoints...');

  // Test different URL patterns
  final testUrls = [
    '/api/v1/auth/register',
    '/api/v1/auth/login',
    '/auth/register',
    '/auth/login',
    '/api/v1/users',
    '/api/auth/register',
    '/v1/auth/register',
  ];

  for (var url in testUrls) {
    print('\n🧪 Testing: $url');
    try {
      // Test with GET first to see if endpoint exists
      final response = await apiClient.get(url);
      print('✅ GET $url - Status: ${response.containsKey('status') ? response['status'] : 'Exists'}');
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        print('❌ GET $url - 404 Not Found');
      } else if (e.statusCode == 405) {
        print('✅ GET $url - Endpoint exists but wrong method (405)');
      } else {
        print('⚠️  GET $url - Status: ${e.statusCode} - ${e.message}');
      }
    } catch (e) {
      print('❌ GET $url - Error: $e');
    }

    await Future.delayed(Duration(milliseconds: 500));
  }
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