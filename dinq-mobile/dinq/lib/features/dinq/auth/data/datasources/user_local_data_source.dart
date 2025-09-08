abstract class UserLocalDataSource {
  Future<void> cacheUserJson(String json);
  Future<String?> getCachedUserJson();
  Future<void> clearCachedUser();

  Future<void> saveFavoriteRestaurantIds(List<String> ids);
  Future<List<String>> getFavoriteRestaurantIds();
  Future<void> clearFavorites();
}
