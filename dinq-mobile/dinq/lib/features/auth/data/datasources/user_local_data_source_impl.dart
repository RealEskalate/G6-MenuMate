import 'package:shared_preferences/shared_preferences.dart';

import 'user_local_data_source.dart';

const _kUserJsonKey = 'cached_user_json';
const _kFavoriteRestaurantIdsKey = 'favorite_restaurant_ids';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences prefs;

  UserLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> cacheUserJson(String json) async {
    await prefs.setString(_kUserJsonKey, json);
  }

  @override
  Future<String?> getCachedUserJson() async {
    return prefs.getString(_kUserJsonKey);
  }

  @override
  Future<void> clearCachedUser() async {
    await prefs.remove(_kUserJsonKey);
  }

  @override
  Future<void> saveFavoriteRestaurantIds(String id) async {
    final current = prefs.getStringList(_kFavoriteRestaurantIdsKey) ?? [];
    if (!current.contains(id)) {
      current.add(id);
      await prefs.setStringList(_kFavoriteRestaurantIdsKey, current);
    }
  }

  @override
  Future<List<String>> getFavoriteRestaurants() async {
    return prefs.getStringList(_kFavoriteRestaurantIdsKey) ?? <String>[];
  }

  @override
  Future<void> clearFavorites() async {
    await prefs.remove(_kFavoriteRestaurantIdsKey);
  }

  @override
  Future<void> deleteFavoriteRestaurantId(String id) async {
    final current = prefs.getStringList(_kFavoriteRestaurantIdsKey) ?? [];
    current.remove(id);
    await prefs.setStringList(_kFavoriteRestaurantIdsKey, current);
  }
}
