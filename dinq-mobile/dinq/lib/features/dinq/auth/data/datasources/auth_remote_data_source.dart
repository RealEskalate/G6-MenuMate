// lib/features/DineQ_App/auth/data/datasources/auth_remote_data_source.dart
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData);
  Future<Map<String, dynamic>> login(String identifier, String password);
  Future<Map<String, dynamic>> createResturant(
      Map<String, dynamic> Resturantdata);
}
