// main.dart - CORRECTED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

<<<<<<< HEAD
// import 'core/injection.dart' as di;
// import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'core/routing/app_route.dart';
// import 'core/temp/app_config.dart';
=======
import 'core/routing/app_route.dart';
// import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
>>>>>>> origin/mite-test
import 'core/util/theme.dart';
// ...existing code...
import 'features/dinq/auth/presentation/bloc/user_bloc.dart';
import 'features/dinq/restaurant_management/presentation/bloc/restaurant_bloc.dart';
<<<<<<< HEAD
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env file before anything else
  await dotenv.load(fileName: ".env");
  // ConfigPresets.developmentDemo();
=======
import 'features/dinq/search/presentation/pages/main_shell.dart';
import 'injection_container.dart' as di;
import 'core/network/token_manager.dart';
import 'features/dinq/auth/presentation/Pages/login_page.dart';
import 'package:dio/dio.dart';
import 'core/network/api_endpoints.dart';
import 'features/dinq/auth/data/datasources/user_local_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
>>>>>>> origin/mite-test
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RestaurantBloc>(
          // create bloc but don't dispatch LoadRestaurants here;
          // HomePage will request restaurants when it has a valid context.
          create: (context) => di.sl<RestaurantBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<UserBloc>(),
        ),
      ],
      child: MaterialApp(
<<<<<<< HEAD
        initialRoute: AppRoute.onboarding,
=======
        // start at an auth gate that decides whether to show login or main shell
        home: const AuthGate(),
>>>>>>> origin/mite-test
        onGenerateRoute: AppRoute.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenManager.getRefreshTokenStatic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final refreshToken = (snapshot.data ?? '');
        if (refreshToken.isEmpty) return const LoginPage();

        // attempt server-side refresh using the named refreshDio
        return FutureBuilder<bool>(
          future: _tryServerRefresh(refreshToken),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final ok = snap.data ?? false;
            if (ok) return const MainShell();
            return const LoginPage();
          },
        );
      },
    );
  }

  Future<bool> _tryServerRefresh(String refreshToken) async {
    try {
      final Dio refreshDio = di.sl<Dio>(instanceName: 'refreshDio');
      final resp = await refreshDio.post(
        ApiEndpoints.refresh,
        data: refreshToken,
        options: Options(headers: {'Content-Type': 'text/plain'}),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        String? newAccess;
        String? newRefresh;
        Map<String, dynamic>? userData;
        if (data is Map) {
          newAccess = data['access_token']?.toString() ??
              data['tokens']?['access_token']?.toString();
          newRefresh = data['refresh_token']?.toString() ??
              data['tokens']?['refresh_token']?.toString();
          userData =
              (data['user'] ?? data['data'] ?? data) as Map<String, dynamic>?;
        }

        if (newAccess != null && newAccess.isNotEmpty) {
          await TokenManager.setAccessTokenStatic(newAccess);
          if (newRefresh != null && newRefresh.isNotEmpty) {
            await TokenManager.setRefreshTokenStatic(newRefresh);
          }

          // persist user and favorites locally if available
          try {
            final local = di.sl<UserLocalDataSource>();
            if (userData != null) {
              local.cacheUserJson(userData.toString());
              final favs = userData['favorites'] as List<dynamic>?;
              if (favs != null) {
                final ids = favs.map((e) => e.toString()).toList();
                await local.saveFavoriteRestaurantIds(ids);
              }
            }
          } catch (_) {}

          return true;
        }
      }
    } catch (_) {}
    await TokenManager.clearTokensStatic();
    return false;
  }
}
