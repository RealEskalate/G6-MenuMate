import 'package:shared_preferences/shared_preferences.dart';

import 'user_local_data_source.dart';

const _kUserJsonKey = 'cached_user_json';
const _kFavoriteRestaurantIdsKey = 'favorite_restaurant_ids';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences prefs;

  UserLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> cacheUserJson(String json) async {
    print('DEBUG: Caching user JSON: ${json.substring(0, 50)}...');
    await prefs.setString(_kUserJsonKey, json);
  }

  @override
  Future<String?> getCachedUserJson() async {
    return prefs.getString(_kUserJsonKey);
  }

  @override
  Future<void> clearCachedUser() async {
    print('DEBUG: Clearing cached user JSON');
    await prefs.remove(_kUserJsonKey);
  }

  @override
  Future<void> saveFavoriteRestaurantIds(List<String> ids) async {
    await prefs.setStringList(_kFavoriteRestaurantIdsKey, ids);
  }

  @override
  Future<List<String>> getFavoriteRestaurantIds() async {
    return prefs.getStringList(_kFavoriteRestaurantIdsKey) ?? <String>[];
  }

  @override
  Future<void> clearFavorites() async {
    await prefs.remove(_kFavoriteRestaurantIdsKey);
  }
}
