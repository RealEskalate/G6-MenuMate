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
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.unknown,
                error: 'Demo mode: Request intercepted',
              ),
            );
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (_isDemoMode) {
            final demoResponse = _getDemoResponse(error.requestOptions);
            final response = Response(
              requestOptions: error.requestOptions,
              statusCode: 200,
              data: demoResponse,
            );
            print(
              '📦 [DEMO MODE] Returning demo response for: ${error.requestOptions.path}',
            );
            return handler.resolve(response);
          }
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
