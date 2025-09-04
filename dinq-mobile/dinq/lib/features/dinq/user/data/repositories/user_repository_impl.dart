import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../model/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo network;

  UserRepositoryImpl({required this.remoteDataSource, required this.network});

  @override
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    String? firstName,
    String? lastName,
    String? role,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final userModel = UserModel(
          id: '',
          username: username,
          email: email,
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          role: role ?? '',
          status: 'ACTIVE',
          authProvider: authProvider,
          isVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final res = await remoteDataSource.registerUser(userModel, password);
        return res;
      } catch (e) {
        throw e;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<Map<String, dynamic>> loginUser({
    required String identifier,
    required String password,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final res = await remoteDataSource.loginUser(identifier, password);
        return res;
      } catch (e) {
        throw e;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<String> getGoogleLoginRedirectUrl() async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        return await remoteDataSource.getGoogleLoginRedirectUrl();
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<Map<String, dynamic>> handleGoogleOAuthCallback({
    required String code,
    String? state,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        return await remoteDataSource.handleGoogleCallback(code, state);
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.forgotPassword(email);
        return;
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<void> logout() async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.logout();
        return;
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.resetPassword(token, newPassword);
        return;
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        return await remoteDataSource.updateProfile(updates);
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.changePassword(currentPassword, newPassword);
        return;
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<void> verifyEmail({required String otp}) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.verifyEmail(otp);
        return;
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<void> resendOtp({required String email}) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.resendOtp(email);
        return;
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }

  @override
  Future<void> verifyOtp({
    required String otp,
    required String identifier,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.verifyOtp(otp, identifier);
        return;
      } catch (e) {
        rethrow;
      }
    }
    throw NetworkException('No internet connection available.');
  }
}
