import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'user_local_data_source.dart';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  UserLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: _accessKey, value: accessToken);
    await secureStorage.write(key: _refreshKey, value: refreshToken);
  }

  @override
  Future<Option<Map<String, String>>> getCachedTokens() async {
    final access = await secureStorage.read(key: _accessKey);
    final refresh = await secureStorage.read(key: _refreshKey);
    if (access != null && refresh != null) {
      return some({'access_token': access, 'refresh_token': refresh});
    }
    return none();
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: _accessKey);
    await secureStorage.delete(key: _refreshKey);
  }
}
