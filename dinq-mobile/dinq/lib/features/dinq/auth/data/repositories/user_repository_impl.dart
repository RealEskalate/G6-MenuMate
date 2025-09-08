import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/network/token_manager.dart';
import '../../domain/entities/user.dart';
import '../datasources/user_local_data_source.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../model/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo network;
  final TokenManager tokenManager;
  final UserLocalDataSource? userLocalDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.network,
    required this.tokenManager,
    this.userLocalDataSource,
  });

  @override
  Future<Either<Failure, User>> registerUser({
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
        final res = await remoteDataSource.registerUser(
          username: username,
          email: email,
          password: password,
          authProvider: authProvider,
          firstName: firstName,
          lastName: lastName,
          role: role,
        );
        // res expected to contain 'user' and 'tokens'
        try {
          final tokens = <String, String>{
            'access_token': (res['tokens']?['access_token'] ?? '').toString(),
            'refresh_token': (res['tokens']?['refresh_token'] ?? '').toString(),
          };
          if (tokens['access_token']!.isNotEmpty &&
              tokens['refresh_token']!.isNotEmpty) {
            await tokenManager.cacheTokens(
              accessToken: tokens['access_token']!,
              refreshToken: tokens['refresh_token']!,
            );
          }
          // cache user JSON and favorites locally if local datasource is available
          try {
            final userJson = (res['user'] ?? {}) is Map
                ? (res['user'] as Map).cast<String, dynamic>().toString()
                : res['user']?.toString();
            if (userJson != null &&
                userJson.isNotEmpty &&
                userLocalDataSource != null) {
              await userLocalDataSource?.cacheUserJson(userJson);
              // if server returns favorites, persist them
              final favs = (res['user'] ?? {})['favorites'] as List<dynamic>?;
              if (favs != null) {
                final ids = favs.map((e) => e.toString()).toList();
                await userLocalDataSource?.saveFavoriteRestaurantIds(ids);
              }
            }
          } catch (_) {}
        } catch (_) {}

        // parse user entity from response
        final userMap = (res['user'] ?? {}) as Map<String, dynamic>;
        final userModel = UserModel.fromMap(userMap);
        return Right(userModel.toEntity());
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> loginUser({
    required String identifier,
    required String password,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final res = await remoteDataSource.loginUser(identifier, password);
        try {
          final access = res['tokens']?['access_token']?.toString() ?? '';
          final refresh = res['tokens']?['refresh_token']?.toString() ?? '';
          if (access.isNotEmpty && refresh.isNotEmpty) {
            await tokenManager.cacheTokens(
              accessToken: access,
              refreshToken: refresh,
            );
          }
          // cache user JSON and favorites locally if available
          try {
            print('here');
            final userJson = (res['user'] ?? {}) is Map
                ? (res['user'] as Map).cast<String, dynamic>().toString()
                : res['user']?.toString();
            if (userJson != null &&
                userJson.isNotEmpty &&
                userLocalDataSource != null) {
              await userLocalDataSource!.cacheUserJson(userJson);
              final favs = (res['user'] ?? {})['favorites'] as List<dynamic>?;
              if (favs != null) {
                final ids = favs.map((e) => e.toString()).toList();
                await userLocalDataSource!.saveFavoriteRestaurantIds(ids);
              }
            }
          } catch (_) {}
        } catch (_) {}
        final userMap = (res['user'] ?? {}) as Map<String, dynamic>;
        final userModel = UserModel.fromMap(userMap);
        return Right(userModel.toEntity());
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, String>> getGoogleLoginRedirectUrl() async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final res = await remoteDataSource.getGoogleLoginRedirectUrl();
        return Right(res);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> handleGoogleOAuthCallback({
    required String code,
    String? state,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final res = await remoteDataSource.handleGoogleCallback(code, state);
        return Right(res);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.forgotPassword(email);
        return const Right(unit);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.logout();
        try {
          await tokenManager.clearTokens();
        } catch (_) {}
        return const Right(unit);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.resetPassword(token, newPassword);
        return const Right(unit);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final res = await remoteDataSource.updateProfile(updates);
        return Right(res);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.changePassword(currentPassword, newPassword);
        return const Right(unit);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> verifyEmail({required String otp}) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.verifyEmail(otp);
        return const Right(unit);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.resendOtp(email);
        return const Right(unit);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String otp,
    required String identifier,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await remoteDataSource.verifyOtp(otp, identifier);
        return const Right(unit);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    }
    return const Left(
      NetworkFailure(
        'No internet connection available. Please check your network settings and try again.',
      ),
    );
  }
}
