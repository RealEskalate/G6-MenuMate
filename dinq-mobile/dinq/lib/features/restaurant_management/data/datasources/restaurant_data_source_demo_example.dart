// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/temp/app_config.dart';
import '../datasources/restaurant_remote_data_source_impl.dart';

/// Example showing how to use the updated RestaurantRemoteDataSource with demo support
class RestaurantDataSourceUsageExample {
  static Future<void> demonstrateUsage() async {
    // 1. Configure demo mode
    print('🚀 Setting up Restaurant DataSource...');
    ConfigPresets.developmentDemo(); // Enable demo mode

    // 2. Setup dependencies (you would use your DI container in real app)
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    // Mock network info (in real app, inject the actual implementation)
  

    // 3. Create data source
    final dataSource = RestaurantRemoteDataSourceImpl(
      dio: dio,
    );

    print('📊 Demo mode status: ${dataSource.isDemoMode}');

    try {
      // 4. Use the data source - it will automatically use demo data
      print('\n🏪 Fetching restaurants...');
      final restaurants = await dataSource.getRestaurants();
      print('✅ Found ${restaurants.length} restaurants:');
      for (final restaurant in restaurants) {
        print('   - ${restaurant.name} (${restaurant.address})');
      }

      if (restaurants.isNotEmpty) {
        // 5. Get menu for first restaurant
        print('\n🍽️  Fetching menu for ${restaurants.first.name}...');
        final menu = await dataSource.getMenu(restaurants.first.id);
        print('✅ Menu has ${menu.tabs.length} tabs');

        if (menu.tabs.isNotEmpty) {
          // 6. Get categories for first tab
          print('\n📂 Fetching categories for ${menu.tabs.first.name}...');
          final categories = await dataSource.getCategories(menu.tabs.first.id);
          print('✅ Found ${categories.length} categories:');
          for (final category in categories) {
            print('   - ${category.name} (${category.items.length} items)');
          }

          if (categories.isNotEmpty && categories.first.items.isNotEmpty) {
            // 7. Get reviews for first item
            final firstItem = categories.first.items.first;
            print('\n⭐ Fetching reviews for ${firstItem.name}...');
            final reviews = await dataSource.getReviews(firstItem.id);
            print('✅ Found ${reviews.length} reviews');

            // 8. Get user images for first item
            print('\n🖼️  Fetching user images for ${firstItem.slug}...');
            final images = await dataSource.getUserImages(firstItem.slug);
            print('✅ Found ${images.length} user images');
          }
        }
      }

      // 9. Demonstrate mode switching
      print('\n🔄 Switching to real API mode...');
      dataSource.toggleDemoMode();
      print('📊 Demo mode status: ${dataSource.isDemoMode}');

      // In real API mode, you would need actual network connection
      // and the backend running for these calls to work

    } catch (e) {
      print('❌ Error: $e');
      print('💡 Make sure you have network connection for real API mode');
    }
  }

  /// Example of how to integrate with your repository
  static void repositoryIntegrationExample() {
    print('''
📋 Repository Integration Example:

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RestaurantRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurants() async {
    try {
      final restaurants = await remoteDataSource.getRestaurants();
      return Right(restaurants);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  // ... other methods
}

// Usage in your app:
final repository = RestaurantRepositoryImpl(
  RestaurantRemoteDataSourceImpl(
    dio: dio,
    network: networkInfo,
  ),
  networkInfo,
);

// The data source will automatically use demo data when AppConfig.useDemoMode = true
''');
  }
}

/// Mock NetworkInfo for demonstration (replace with your actual implementation)
class MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected => Future.value(true);
}
