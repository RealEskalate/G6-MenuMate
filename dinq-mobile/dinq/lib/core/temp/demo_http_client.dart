// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'demo_api_responses.dart';

/// Mock HTTP client for demo purposes
/// This client intercepts HTTP requests and returns demo responses
class DemoHttpClient {
  final Dio _dio;
  bool _isDemoMode = true;

  DemoHttpClient(this._dio) {
    _setupInterceptors();
  }

  /// Enable or disable demo mode
  void setDemoMode(bool enabled) {
    _isDemoMode = enabled;
  }

  /// Check if demo mode is enabled
  bool get isDemoMode => _isDemoMode;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_isDemoMode) {
            print(
              '🚀 [DEMO MODE] Intercepting request: ${options.method} ${options.path}',
            );

            // Get demo response directly in request interceptor
            final demoResponse = _getDemoResponse(options);

            if (demoResponse != null) {
              print(
                '📦 [DEMO MODE] Returning demo response for: ${options.path}',
              );

              // Resolve with demo data instead of rejecting
              final response = Response(
                requestOptions: options,
                statusCode: 200,
                statusMessage: 'Demo Response',
                data: demoResponse,
              );

              return handler.resolve(response);
            } else {
              print(
                '❌ [DEMO MODE] No demo response found for: ${options.path}',
              );
              print('📋 Check demo_api_responses.dart for available endpoints');
            }
          }

          // If not demo mode or no demo response, proceed normally
          return handler.next(options);
        },
        onError: (error, handler) {
          // Keep error handling for non-demo cases
          print('⚠️ [DEMO MODE] Error interceptor called: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  dynamic _getDemoResponse(RequestOptions options) {
    final path = options.path;
    final method = options.method;

    // Get demo response based on endpoint
    final responseJson = DemoApiResponses.getDemoResponse('$method $path');

    // Parse based on expected response type
    if (_isListResponse(path)) {
      return DemoApiResponses.parseResponseList(responseJson);
    } else {
      return DemoApiResponses.parseResponse(responseJson);
    }
  }

  bool _isListResponse(String path) {
    // Endpoints that return lists
    return path.contains('/restaurants') && !path.contains('/menu') ||
        path.contains('/categories') ||
        path.contains('/reviews') ||
        path.contains('/images');
  }

  /// Get the underlying Dio instance
  Dio get dio => _dio;
}

/// Extension to easily enable demo mode on Dio instances
extension DioDemoExtension on Dio {
  /// Enable demo mode for this Dio instance
  void enableDemoMode() {
    DemoHttpClient(this).setDemoMode(true);
  }

  /// Disable demo mode for this Dio instance
  void disableDemoMode() {
    DemoHttpClient(this).setDemoMode(false);
  }
}
