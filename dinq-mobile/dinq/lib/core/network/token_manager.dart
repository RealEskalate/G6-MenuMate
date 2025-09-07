import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  static Future<void> saveTokens(String accessToken, String refreshToken, {int expiryMinutes = 15}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(Duration(minutes: expiryMinutes)).millisecondsSinceEpoch;

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_tokenExpiryKey, expiryTime);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_accessTokenKey);

    // If no token in SharedPreferences, use the hardcoded token from constants
    if (token == null || token.isEmpty) {
      token = accessToken;
    }

    return token;
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = prefs.getInt(_tokenExpiryKey);

    if (expiryTime == null) return true;

    return DateTime.now().millisecondsSinceEpoch > expiryTime;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

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
  }
}