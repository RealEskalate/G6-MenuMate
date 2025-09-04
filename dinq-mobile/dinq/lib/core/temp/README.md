# Demo API Tools for MenuMate Mobile App

This directory contains comprehensive demo tools that allow you to develop and test your Flutter app without needing a live backend API.

## 📁 Files Overview

| File                      | Purpose                                          |
| ------------------------- | ------------------------------------------------ |
| `demo_api_responses.dart` | Mock JSON responses for all API endpoints        |
| `demo_http_client.dart`   | HTTP interceptor that returns demo data          |
| `demo_usage_example.dart` | Integration examples and usage patterns          |
| `app_config.dart`         | Global configuration for demo vs production mode |

## 🚀 Quick Start

### 1. Enable Demo Mode Globally

```dart
import 'core/temp/app_config.dart';

// Enable demo mode for development
AppConfig.enableDemoMode();

// Or use preset
ConfigPresets.developmentDemo();
```

### 2. Setup HTTP Client with Demo Support

```dart
import 'package:dio/dio.dart';
import 'core/temp/demo_http_client.dart';

final dio = Dio(BaseOptions(
  baseUrl: AppConfig.baseUrl,
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));

final demoClient = DemoHttpClient(dio);

// Demo mode is automatically enabled if AppConfig.useDemoMode is true
```

### 3. Use in Your Data Sources

```dart
import '../temp/demo_http_client.dart';

class RestaurantRemoteDataSource {
  final Dio _dio;
  late final DemoHttpClient _demoClient;

  RestaurantRemoteDataSource(this._dio) {
    _demoClient = DemoHttpClient(_dio);
  }

  Future<List<RestaurantModel>> getRestaurants() async {
    final response = await _dio.get('/restaurants');

    // Demo client automatically returns mock data
    final data = response.data as List;
    return data.map((json) => RestaurantModel.fromMap(json)).toList();
  }
}
```

## 🎯 API Endpoints Covered

### Restaurants

- `GET /restaurants` → List all restaurants
- `PUT /restaurants/{id}` → Update restaurant

### Menu Management

- `GET /restaurants/{id}/menu` → Get restaurant menu with tabs
- `GET /tabs/{id}/categories` → Get categories for a tab

### Items & Reviews

- `GET /items/{id}/reviews` → Get item reviews
- `GET /items/{slug}/images` → Get user uploaded images
- `PUT /items/{id}` → Update item

## 🔧 Configuration Options

### Environment Modes

```dart
// Development with demo data (recommended)
ConfigPresets.developmentDemo();

// Development with real API
ConfigPresets.developmentReal();

// Production
ConfigPresets.production();
```

### Manual Configuration

```dart
// Toggle demo mode
AppConfig.toggleDemoMode();

// Check current status
print('Demo mode: ${AppConfig.isDemoMode}');

// Print full config
AppConfig.printConfig();
```

## 📊 Sample Data

The demo responses include realistic Ethiopian restaurant data:

- **3 Sample Restaurants**: Traditional Ethiopian cuisine
- **Complete Menus**: Tabs → Categories → Items structure
- **Authentic Dishes**: Doro Wat, Tibs, Misir Wat, etc.
- **Customer Reviews**: Ratings and comments
- **Images**: Sample URLs for restaurant photos

## 🧪 Testing Integration

### Unit Testing

```dart
void main() {
  test('Restaurant data source returns demo data', () async {
    // Setup
    AppConfig.enableDemoMode();
    final dio = Dio();
    final dataSource = RestaurantRemoteDataSource(dio);

    // Test
    final restaurants = await dataSource.getRestaurants();

    // Assert
    expect(restaurants, isNotEmpty);
    expect(restaurants.first.name, contains('Restaurant'));
  });
}
```

### Widget Testing

```dart
void main() {
  testWidgets('Restaurant list shows demo data', (tester) async {
    // Enable demo mode
    AppConfig.enableDemoMode();

    // Build your widget
    await tester.pumpWidget(MyApp());

    // Test with demo data
    expect(find.text('Mama\'s Kitchen'), findsOneWidget);
  });
}
```

## 🔄 Switching Between Modes

### Development Workflow

1. **Start with Demo Mode**:

   ```dart
   ConfigPresets.developmentDemo();
   ```

   - Build UI components
   - Test user flows
   - No backend required

2. **Switch to Real API**:

   ```dart
   ConfigPresets.developmentReal();
   ```

   - Test with actual backend
   - Integration testing
   - API contract validation

3. **Production**:
   ```dart
   ConfigPresets.production();
   ```
   - Live app deployment
   - Real data only

## 📝 Best Practices

### 1. Environment-Specific Setup

```dart
void main() {
  // Set environment based on build flavor
  const bool isDemo = String.fromEnvironment('DEMO_MODE') == 'true';
  if (isDemo) {
    ConfigPresets.developmentDemo();
  } else {
    ConfigPresets.production();
  }

  runApp(MyApp());
}
```

### 2. Feature Flags

```dart
class FeatureFlags {
  static bool useDemoData = AppConfig.isDemoMode;

  static Future<List<Restaurant>> getRestaurants() {
    return useDemoData
        ? DemoDataService.getRestaurants()
        : RealApiService.getRestaurants();
  }
}
```

### 3. Logging

```dart
class ApiLogger {
  static void logRequest(String endpoint, {bool isDemo = false}) {
    print('${isDemo ? '🎭 DEMO' : '🌐 REAL'} Request: $endpoint');
  }
}
```

## 🚨 Important Notes

- **Demo mode intercepts all HTTP requests** - no real API calls are made
- **Data is static** - same responses every time for consistency
- **No authentication required** - all endpoints work without tokens
- **Fast responses** - instant data for smooth development
- **Type-safe** - all responses match your model structures

## 🎉 Benefits

✅ **Faster Development** - No backend dependency
✅ **Consistent Testing** - Same data every time
✅ **Offline Development** - Work without internet
✅ **UI/UX Focus** - Build beautiful interfaces first
✅ **API Contract** - Validate your models against expected data
✅ **Team Collaboration** - Everyone works with same demo data

---

Happy coding! 🎯 Your MenuMate app is ready for development with full demo support.
