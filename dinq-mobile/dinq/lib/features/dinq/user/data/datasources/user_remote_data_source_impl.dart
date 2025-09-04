import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../model/user_model.dart';
import 'user_remote_data_source.dart';

const String content = 'application/json';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> registerUser(
    UserModel user,
    String password,
  ) async {
    print('[Remote] registerUser - POST /auth/register');
    try {
      final data = user.toMap()..addAll({'password': password});
      final response = await dio.post(
        '$baseUrl/auth/register',
        data: data,
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      print('[Remote] registerUser - status=$statusCode data=${response.data}');
      if (statusCode == 200 || statusCode == 201) {
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
    print('[Remote] loginUser - POST /auth/login');
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {'identifier': identifier, 'password': password},
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      print('[Remote] loginUser - status=$statusCode data=${response.data}');
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
    print('[Remote] getGoogleLoginRedirectUrl - GET /auth/google/login');
    try {
      final response = await dio.get(
        '$baseUrl/auth/google/login',
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
    print('[Remote] handleGoogleCallback - GET /auth/google/callback');
    try {
      final uri = Uri.parse('$baseUrl/auth/google/callback').replace(
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
    print('[Remote] forgotPassword - POST /auth/forgot-password');
    try {
      final response = await dio.post(
        '$baseUrl/auth/forgot-password',
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
    print('[Remote] logout - POST /auth/logout');
    try {
      final response = await dio.post(
        '$baseUrl/auth/logout',
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
    print('[Remote] resetPassword - POST /auth/reset-password');
    try {
      final response = await dio.post(
        '$baseUrl/auth/reset-password',
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
    print('[Remote] updateProfile - PATCH /auth/profile');
    try {
      final response = await dio.patch(
        '$baseUrl/auth/profile',
        data: updates,
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200)
        return (response.data as Map).cast<String, dynamic>();
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
    print('[Remote] changePassword - PATCH /auth/change-password');
    try {
      final response = await dio.patch(
        '$baseUrl/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
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
    print('[Remote] verifyEmail - POST /auth/verify-email');
    try {
      final response = await dio.post(
        '$baseUrl/auth/verify-email',
        data: {'otp': otp},
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
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
    print('[Remote] resendOtp - POST /auth/resend-otp');
    try {
      final response = await dio.post(
        '$baseUrl/auth/resend-otp',
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
    print('[Remote] verifyOtp - POST /auth/verify-otp');
    try {
      final response = await dio.post(
        '$baseUrl/auth/verify-otp',
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
