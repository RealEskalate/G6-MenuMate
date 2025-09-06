// lib/features/DineQ_App/auth/data/datasources/auth_remote_data_source_impl.dart
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> registerUser(
    Map<String, dynamic> userData,
  ) async {
    print('trying to signup');
    return await apiClient.post(ApiEndpoints.register, body: userData);
  }

  @override
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    return await apiClient.post(
      ApiEndpoints.login,
      body: {'identifier': identifier, 'password': password},
    );
  }
}
