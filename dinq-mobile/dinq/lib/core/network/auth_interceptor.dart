import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'token_manager.dart';

/// Interceptor that refreshes access tokens on 401 responses.
class AuthInterceptor extends Interceptor {
  final TokenManager tokenManager;
  final Dio refreshDio;
  final int maxAttempts;

  Future<void>? _refreshFuture;

  AuthInterceptor({
    required this.tokenManager,
    required this.refreshDio,
    this.maxAttempts = 2,
  });

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final reqOptions = err.requestOptions;

    if (response?.statusCode == 401) {
      final int attempts = (reqOptions.extra['refresh_attempts'] as int?) ?? 0;
      if (attempts >= maxAttempts) return handler.next(err);

      try {
        // coalesce parallel refreshes
        if (_refreshFuture == null) {
          _refreshFuture = _doRefresh();
          await _refreshFuture;
          _refreshFuture = null;
        } else {
          await _refreshFuture;
        }

        final newAccess = await TokenManager.getAccessTokenStatic();
        if (newAccess == null || newAccess.isEmpty) {
          await TokenManager.clearTokensStatic();
          return handler.next(err);
        }

        // prepare headers and extra
        final headers = Map<String, dynamic>.from(reqOptions.headers);
        headers['Authorization'] = 'Bearer $newAccess';
        final extra = Map<String, dynamic>.from(reqOptions.extra);
        extra['refresh_attempts'] = attempts + 1;

        final options = Options(method: reqOptions.method, headers: headers);

        // retry the original request using the main Dio instance (refreshDio is only for refresh)
        final retryResponse = await refreshDio.request(
          reqOptions.path,
          data: reqOptions.data,
          queryParameters: reqOptions.queryParameters,
          options: options.copyWith(extra: extra),
        );

        return handler.resolve(retryResponse);
      } catch (e) {
        await TokenManager.clearTokensStatic();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<void> _doRefresh() async {
    final refreshToken = await TokenManager.getRefreshTokenStatic();
    if (refreshToken == null || refreshToken.isEmpty)
      throw Exception('no refresh token');

    final resp = await refreshDio.post(
      ApiEndpoints.refresh,
      data: refreshToken,
      options: Options(headers: {'Content-Type': 'text/plain'}),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = resp.data;
      String? newAccess;
      String? newRefresh;
      if (data is Map) {
        newAccess = data['access_token']?.toString() ??
            data['tokens']?['access_token']?.toString();
        newRefresh = data['refresh_token']?.toString() ??
            data['tokens']?['refresh_token']?.toString();
      }

      if (newAccess != null && newAccess.isNotEmpty) {
        await TokenManager.setAccessTokenStatic(newAccess);
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await TokenManager.setRefreshTokenStatic(newRefresh);
        }
        return;
      }
    }

    throw Exception('refresh failed');
  }
}
