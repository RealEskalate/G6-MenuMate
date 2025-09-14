import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> registerUser({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    required String role,
    String? firstName,
    String? lastName,
  });

  Future<Either<Failure, User>> loginUser({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, String>> getGoogleLoginRedirectUrl();

  Future<Either<Failure, Map<String, dynamic>>> handleGoogleOAuthCallback({
    required String code,
    String? state,
  });

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> updates,
  );

  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, Unit>> verifyEmail({required String otp});

  Future<Either<Failure, Unit>> resendOtp({required String email});

  Future<Either<Failure, Unit>> verifyOtp({
    required String otp,
    required String identifier,
  });

  // Local data source methods
  Future<Either<Failure, Unit>> cacheUserJson(User user);
  Future<Either<Failure, User>> getCachedUserJson();
  Future<Either<Failure, Unit>> clearCachedUser();
  Future<Either<Failure, Unit>> saveFavoriteRestaurantIds(String id);
  Future<Either<Failure, List<String>>> getFavoriteRestaurants();
  Future<Either<Failure, Unit>> deleteFavoriteRestaurantId(String id);
  Future<Either<Failure, Unit>> clearFavorites();
}
