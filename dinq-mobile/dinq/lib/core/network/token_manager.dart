import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  final FlutterSecureStorage secureStorage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  TokenManager({required this.secureStorage});

  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    print(
        'DEBUG: Caching tokens - access: ${accessToken.substring(0, 10)}..., refresh: ${refreshToken.substring(0, 10)}...');
    await secureStorage.write(key: _accessKey, value: accessToken);
    await secureStorage.write(key: _refreshKey, value: refreshToken);
  }

  Future<Option<Map<String, String>>> getCachedTokens() async {
    final access = await secureStorage.read(key: _accessKey);
    final refresh = await secureStorage.read(key: _refreshKey);
    if (access != null && refresh != null) {
      return some({'access_token': access, 'refresh_token': refresh});
    }
    return none();
  }

  Future<void> clearTokens() async {
    print('DEBUG: Clearing tokens from storage');
    await secureStorage.delete(key: _accessKey);
    await secureStorage.delete(key: _refreshKey);
  }

  // Static helpers for small, non-invasive usage from datasources
  // These avoid changing DI/constructors across the codebase.
  static final FlutterSecureStorage _staticStorage =
      const FlutterSecureStorage();

  /// Returns the cached access token or null.
  static Future<String?> getAccessTokenStatic() async {
    try {
      final token = await _staticStorage.read(key: _accessKey);
      return token;
    } catch (_) {
      return null;
    }
  }

  /// Returns authorization headers map if token exists, otherwise empty map.
  static Future<Map<String, String>> getAuthHeadersStatic() async {
    final token = await getAccessTokenStatic();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  /// Write access token to static storage.
  static Future<void> setAccessTokenStatic(String token) async {
    try {
      await _staticStorage.write(key: _accessKey, value: token);
    } catch (_) {}
  }

  /// Write refresh token to static storage.
  static Future<void> setRefreshTokenStatic(String token) async {
    try {
      await _staticStorage.write(key: _refreshKey, value: token);
    } catch (_) {}
  }

  /// Read refresh token (raw) from storage.
  static Future<String?> getRefreshTokenStatic() async {
    try {
      return await _staticStorage.read(key: _refreshKey);
    } catch (_) {
      return null;
    }
  }

  /// Clear both tokens via static storage.
  static Future<void> clearTokensStatic() async {
    try {
      await _staticStorage.delete(key: _accessKey);
      await _staticStorage.delete(key: _refreshKey);
    } catch (_) {}
  }

  /// Get cached tokens via static storage.
  static Future<Map<String, String>?> getCachedTokensStatic() async {
    try {
      final access = await _staticStorage.read(key: _accessKey);
      final refresh = await _staticStorage.read(key: _refreshKey);
      if (access != null && refresh != null) {
        return {'access_token': access, 'refresh_token': refresh};
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
