<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
=======
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
>>>>>>> origin/mite-test

class TokenManager {
  final FlutterSecureStorage secureStorage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  TokenManager({required this.secureStorage});

  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: _accessKey, value: accessToken);
    await secureStorage.write(key: _refreshKey, value: refreshToken);
  }

<<<<<<< HEAD
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_accessTokenKey);

    // If no token in SharedPreferences, use the hardcoded token from constants
    if (token == null || token.isEmpty) {
      token = accessToken;
    }

    return token;
=======
  Future<Option<Map<String, String>>> getCachedTokens() async {
    final access = await secureStorage.read(key: _accessKey);
    final refresh = await secureStorage.read(key: _refreshKey);
    if (access != null && refresh != null) {
      return some({'access_token': access, 'refresh_token': refresh});
    }
    return none();
>>>>>>> origin/mite-test
  }

  Future<void> clearTokens() async {
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

<<<<<<< HEAD
  static Future<Map<String, String>?> getAuthHeaders() async {
    String? token = await getAccessToken();
    print('🔍 TokenManager.getAuthHeaders - SharedPreferences token: ${token != null ? token.substring(0, 20) + "..." : "null"}');

    // If no token in SharedPreferences, use the hardcoded token from constants
    if (token == null || token.isEmpty) {
      token = accessToken;
      print('🔄 Using hardcoded token from constants: ${token != null ? token.substring(0, 20) + "..." : "null"}');
    }

    if (token == null || token.isEmpty) {
      print('❌ No token available!');
      return null;
    }

    print('✅ Using token: ${token.substring(0, 20)}...');
    
    // For multipart requests, don't include Content-Type
    return {
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>?> getAuthHeadersWithContentType() async {
    final headers = await getAuthHeaders();
    if (headers == null) return null;

    return {
      ...headers,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
=======
  /// Write access token to static storage.
  static Future<void> setAccessTokenStatic(String token) async {
    try {
      await _staticStorage.write(key: _accessKey, value: token);
    } catch (_) {}
>>>>>>> origin/mite-test
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
}
