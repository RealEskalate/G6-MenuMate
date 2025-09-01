// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

import '../temp/demo_api_responses.dart';
import '../temp/demo_http_client.dart';

/// Example implementation showing how to use the demo HTTP client
/// This demonstrates integration with your existing data sources
class ExampleRestaurantDataSource {
  final Dio _dio;
  late final DemoHttpClient _demoClient;

  ExampleRestaurantDataSource(this._dio) {
    _demoClient = DemoHttpClient(_dio);
    // Enable demo mode by default for development
    _demoClient.setDemoMode(true);
  }

  /// Toggle between demo mode and real API
  void toggleDemoMode() {
    _demoClient.setDemoMode(!_demoClient.isDemoMode);
    print('🔄 Demo mode: ${_demoClient.isDemoMode ? 'ENABLED' : 'DISABLED'}');
  }

  /// Example: Get all restaurants
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      final response = await _dio.get('/restaurants');

      if (_demoClient.isDemoMode) {
        // In demo mode, response.data is already parsed
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        // In real mode, parse the JSON response
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print('Error fetching restaurants: $e');
      rethrow;
    }
  }

  /// Example: Get restaurant menu
  Future<Map<String, dynamic>> getRestaurantMenu(String restaurantId) async {
    try {
      final response = await _dio.get('/restaurants/$restaurantId/menu');

      if (_demoClient.isDemoMode) {
        // Demo response is already parsed
        return Map<String, dynamic>.from(response.data);
      } else {
        // Real API response needs parsing
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      print('Error fetching menu: $e');
      rethrow;
    }
  }

  /// Example: Get categories for a tab
  Future<List<Map<String, dynamic>>> getCategories(String tabId) async {
    try {
      final response = await _dio.get('/tabs/$tabId/categories');

      if (_demoClient.isDemoMode) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  /// Example: Get reviews for an item
  Future<List<Map<String, dynamic>>> getItemReviews(String itemId) async {
    try {
      final response = await _dio.get('/items/$itemId/reviews');

      if (_demoClient.isDemoMode) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      rethrow;
    }
  }

  /// Example: Update restaurant
  Future<Map<String, dynamic>> updateRestaurant(
    String restaurantId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _dio.put(
        '/restaurants/$restaurantId',
        data: updateData,
      );

      if (_demoClient.isDemoMode) {
        return Map<String, dynamic>.from(response.data);
      } else {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      print('Error updating restaurant: $e');
      rethrow;
    }
  }

  /// Get current demo mode status
  bool get isDemoMode => _demoClient.isDemoMode;

  /// Direct access to demo responses for testing
  String getDemoResponse(String endpoint) {
    return DemoApiResponses.getDemoResponse(endpoint);
  }
}

/// Usage example in your app
class DemoUsageExample {
  static void demonstrateUsage() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.yourrestaurantapp.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    final dataSource = ExampleRestaurantDataSource(dio);

    print('🚀 Starting demo...');

    // Example: Toggle demo mode
    print('Current demo mode: ${dataSource.isDemoMode}');

    // Example: Get demo response directly
    final restaurantsJson = dataSource.getDemoResponse('GET /restaurants');
    print('📋 Sample restaurants response:');
    print(restaurantsJson);

    // In your actual implementation, you would call:
    // final restaurants = await dataSource.getRestaurants();
    // final menu = await dataSource.getRestaurantMenu('restaurant-1');
  }
}
