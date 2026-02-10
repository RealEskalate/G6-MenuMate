import 'package:fpdart/fpdart.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../entities/Auth_response.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        body: {
          'username': username,
          'email': email,
          'password': password,
          'authProvider': authProvider,
          'role': role,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        },
      );

      final authResponse = AuthResponse.fromJson(response);
      return Right(authResponse);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response);
      return Right(authResponse);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await apiClient.post('/auth/logout');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await apiClient.post('/auth/forgot-password', body: {'email': email});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await apiClient.post('/auth/reset-password', body: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsernameAvailability(String username) async {
    try {
      final response = await apiClient.get('/auth/check-username/$username');
      return Right(response['available'] as bool);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailAvailability(String email) async {
    try {
      final response = await apiClient.get('/auth/check-email/$email');
      return Right(response['available'] as bool);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPhoneAvailability(String phoneNumber) async {
    try {
      final response = await apiClient.get('/auth/check-phone/$phoneNumber');
      return Right(response['available'] as bool);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }
}
