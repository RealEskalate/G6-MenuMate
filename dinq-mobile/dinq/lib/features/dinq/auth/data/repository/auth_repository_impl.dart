// lib/features/DineQ_App/auth/data/repositories/auth_repository_impl.dart
import 'package:dinq/core/network/api_client.dart';
import 'package:dinq/core/network/api_endpoints.dart';
import 'package:dinq/core/network/api_exceptions.dart';
import 'package:dinq/core/network/token_manager.dart';
import 'package:dinq/features/dinq/auth/domain/repository/Customer_reg_repo.dart';
import 'package:dinq/features/dinq/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<UserModel> registerUser({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String role = 'CUSTOMER',
  }) async {
    try {
      final userData = {
        'username': username,
        'email': email,
        'password': password,
        'auth_provider': authProvider,
        'role': role,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      };

      print('📨 Registering user with data: $userData');

      final response = await _apiClient.post(ApiEndpoints.register, body: userData);

      print('✅ Registration response: $response');

      return UserModel.fromJson(response);

    } on ApiException catch (e) {
      print('❌ Registration API error: ${e.message}');
      throw ApiException(
        message: _getRegisterErrorMessage(e),
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('❌ Registration unexpected error: $e');
      throw ApiException(
        message: 'Registration failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginData = {
        'identifier': email, // API uses 'identifier' field
        'password': password,
      };

      print('🔐 Logging in with identifier: $email');

      final response = await _apiClient.post(ApiEndpoints.login, body: loginData);

      print('✅ Login response received: $response');

      // API returns tokens, not user data
      if (response.containsKey('access_token') && response.containsKey('refresh_token')) {
        // Store tokens
        await TokenManager.saveTokens(
          response['access_token'],
          response['refresh_token'],
        );

        print('✅ Tokens stored successfully');

        // Return a minimal UserModel with just the identifier
        // In a real app, you might want to fetch user profile separately
        return UserModel(
          id: 'temp_id', // Temporary ID since we don't have user data
          username: email, // Use email as username for now
          email: email,
          password: '', // Don't store password
          role: 'CUSTOMER',
          authprovider: 'EMAIL',
        );
      } else {
        throw ApiException(
          message: 'Invalid login response format - missing tokens',
          statusCode: 500,
        );
      }

    } on ApiException catch (e) {
      print('❌ Login API error: ${e.message}');
      throw ApiException(
        message: _getLoginErrorMessage(e),
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('❌ Login unexpected error: $e');
      throw ApiException(
        message: 'Login failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🚪 Logging out');

      // Clear tokens first
      await TokenManager.clearTokens();
      print('✅ Tokens cleared locally');

      // Try to logout on server (optional, since tokens are stateless)
      try {
        await _apiClient.post(ApiEndpoints.logout);
        print('✅ Server logout successful');
      } catch (serverError) {
        print('⚠️ Server logout failed, but local logout successful: $serverError');
        // Don't throw error for server logout failure since tokens are already cleared
      }

    } on ApiException catch (e) {
      print('❌ Logout API error: ${e.message}');
      throw ApiException(
        message: 'Logout failed: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('❌ Logout unexpected error: $e');
      throw ApiException(
        message: 'Logout failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      print('📧 Sending forgot password email to: $email');
      await _apiClient.post(ApiEndpoints.forgotPassword, body: {'email': email});
      print('✅ Forgot password email sent');
    } on ApiException catch (e) {
      print('❌ Forgot password API error: ${e.message}');
      throw ApiException(
        message: 'Password reset request failed: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('❌ Forgot password unexpected error: $e');
      throw ApiException(
        message: 'Password reset request failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      print('🔄 Resetting password for: $email');
      await _apiClient.post(ApiEndpoints.resetPassword, body: {
        'email': email,
        'token': token,
        'new_password': newPassword,
      });
      print('✅ Password reset successful');
    } on ApiException catch (e) {
      print('❌ Reset password API error: ${e.message}');
      throw ApiException(
        message: 'Password reset failed: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('❌ Reset password unexpected error: $e');
      throw ApiException(
        message: 'Password reset failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      print('🔍 Checking username availability: $username');
      final response = await _apiClient.get('${ApiEndpoints.checkUsername}/$username');
      final isAvailable = response['available'] ?? false;
      print('✅ Username available: $isAvailable');
      return isAvailable;
    } on ApiException catch (e) {
      if (e.statusCode == 409) return false; // Username exists
      print('❌ Username check API error: ${e.message}');
      throw ApiException(
        message: 'Username availability check failed: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('❌ Username check unexpected error: $e');
      throw ApiException(
        message: 'Username availability check failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> checkEmailAvailability(String email) async {
    try {
      print('🔍 Checking email availability: $email');
      final response = await _apiClient.get('${ApiEndpoints.checkEmail}/$email');
      final isAvailable = response['available'] ?? false;
      print('✅ Email available: $isAvailable');
      return isAvailable;
    } on ApiException catch (e) {
      if (e.statusCode == 409) return false; // Email exists
      print('❌ Email check API error: ${e.message}');
      throw ApiException(
        message: 'Email availability check failed: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('❌ Email check unexpected error: $e');
      throw ApiException(
        message: 'Email availability check failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> checkPhoneAvailability(String phoneNumber) async {
    try {
      print('🔍 Checking phone availability: $phoneNumber');
      final response = await _apiClient.get('${ApiEndpoints.checkPhone}/$phoneNumber');
      final isAvailable = response['available'] ?? false;
      print('✅ Phone available: $isAvailable');
      return isAvailable;
    } on ApiException catch (e) {
      if (e.statusCode == 409) return false; // Phone exists
      print('❌ Phone check API error: ${e.message}');
      throw ApiException(
        message: 'Phone availability check failed: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('❌ Phone check unexpected error: $e');
      throw ApiException(
        message: 'Phone availability check failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Error message handling
  String _getRegisterErrorMessage(ApiException e) {
    if (e.statusCode == 409) {
      if (e.message.toLowerCase().contains('username')) {
        return 'Username already exists';
      } else if (e.message.toLowerCase().contains('email')) {
        return 'Email already registered';
      } else if (e.message.toLowerCase().contains('phone')) {
        return 'Phone number already registered';
      }
    } else if (e.statusCode == 400) {
      return 'Invalid registration data';
    }
    return e.message;
  }

  String _getLoginErrorMessage(ApiException e) {
    if (e.statusCode == 401) {
      return 'Invalid email or password';
    } else if (e.statusCode == 404) {
      return 'User not found';
    }
    return e.message;
  }
}