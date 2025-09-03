import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection.dart' as di;
import 'core/temp/app_config.dart';
import 'features/restaurant_management/presentation/bloc/restaurant_bloc.dart';
import 'features/restaurant_management/presentation/pages/settings_page.dart';
import 'features/restaurant_management/presentation/pages/restaurant_profile_page.dart';
import 'features/restaurant_management/presentation/pages/restaurant_details_page.dart';
import 'features/restaurant_management/presentation/pages/opening_hours_page.dart';
import 'features/restaurant_management/presentation/pages/legal_info_page.dart';
import 'features/restaurant_management/presentation/pages/branding_preferences_page.dart';
import 'features/restaurant_management/presentation/pages/billing_page.dart';
import 'features/restaurant_management/presentation/widgets/time_picker_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConfigPresets.developmentDemo();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RestaurantBloc>(
          create: (context) => di.sl<RestaurantBloc>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'DinQ',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SettingsPage(),
        routes: {
          '/restaurant_profile': (context) => const RestaurantProfilePage(),
          '/restaurant_details': (context) => const RestaurantDetailsPage(),
          '/opening_hours': (context) => const OpeningHoursPage(),
          '/legal_info': (context) => const LegalInfoPage(),
          '/branding_preferences': (context) => const BrandingPreferencesPage(),
          '/billing': (context) => const BillingPage(),
        },
      ),
    );
  }
}


