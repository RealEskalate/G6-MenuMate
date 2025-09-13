abstract class UserLocalDataSource {
  Future<void> cacheUserJson(String json);
  Future<String?> getCachedUserJson();
  Future<void> clearCachedUser();

  Future<void> saveFavoriteRestaurantIds(String id);
  Future<List<String>> getFavoriteRestaurants();
  Future<void> deleteFavoriteRestaurantId(String id);
  Future<void> clearFavorites();
}
