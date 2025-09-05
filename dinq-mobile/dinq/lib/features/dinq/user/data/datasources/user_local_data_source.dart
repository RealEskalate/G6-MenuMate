import 'package:dartz/dartz.dart';

abstract class UserLocalDataSource {
  /// Stores access and refresh tokens securely.
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Returns stored tokens as a Map with keys 'access_token' and 'refresh_token', or null if missing.
  Future<Option<Map<String, String>>> getCachedTokens();

  /// Clears stored tokens.
  Future<void> clearTokens();
}
