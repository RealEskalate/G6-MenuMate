import 'package:dio/dio.dart';

import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/token_manager.dart';
import 'user_remote_data_source.dart';

const String content = 'application/json';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    required String role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final data = {
        'auth_provider': authProvider,
        'email': email,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        'password': password,
        'role': role,
        'username': username,
      };
      final response = await dio.post(
        ApiEndpoints.register,
        data: data,
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        // return full response so caller can access user and tokens
        return (response.data as Map).cast<String, dynamic>();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(statusCode, 'registering user'),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'registering user'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while registering user: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> loginUser(
    String identifier,
    String password,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'identifier': identifier, 'password': password},
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return (response.data as Map).cast<String, dynamic>();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(statusCode, 'logging in'),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'logging in'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while logging in: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> getGoogleLoginRedirectUrl() async {
    try {
      final response = await dio.get(
        ApiEndpoints.googleLogin,
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final data = response.data;
        if (data is Map && data['url'] is String) return data['url'] as String;
        return response.data.toString();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'getting google redirect',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'getting google redirect',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while getting google redirect: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> handleGoogleCallback(
    String code,
    String? state,
  ) async {
    try {
      final uri = Uri.parse(ApiEndpoints.googleCallback).replace(
        queryParameters: {'code': code, if (state != null) 'state': state},
      );
      final response = await dio.getUri(
        uri,
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return (response.data as Map).cast<String, dynamic>();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(statusCode, 'google callback'),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'google callback'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while handling google callback: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) return;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'forgot password'),
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'forgot password'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while requesting forgot password: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await dio.post(
        ApiEndpoints.logout,
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) return;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'logout'),
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'logout'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while logging out: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'new_password': newPassword},
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) return;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'reset password'),
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'reset password'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while resetting password: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.patch(
        ApiEndpoints.profile,
        data: updates,
        options: Options(headers: headers),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return (response.data as Map).cast<String, dynamic>();
      }
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'update profile'),
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'update profile'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while updating profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.patch(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(headers: headers),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) return;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'change password'),
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'change password'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while changing password: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> verifyEmail(String otp) async {
    try {
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.post(
        ApiEndpoints.verifyEmail,
        data: {'otp': otp},
        options: Options(headers: headers),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) return;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'verify email'),
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'verify email'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while verifying email: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> resendOtp(String email) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resendOtp,
        data: {'email': email},
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) return;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'resend otp'),
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'resend otp'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while resending otp: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> verifyOtp(String otp, String identifier) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyOtp,
        data: {'otp': otp, 'identifier': identifier},
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) return;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'verify otp'),
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'verify otp'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while verifying otp: ${e.toString()}',
      );
    }
  }
}
