// lib/features/DineQ_App/auth/domain/repository/auth_repository.dart
import 'package:fpdart/fpdart.dart';
import '../../../../../core/error/failures.dart';
import '../../data/entities/Auth_response.dart';
import '../entities/customer_registration.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, bool>> checkUsernameAvailability(String username);

  Future<Either<Failure, bool>> checkEmailAvailability(String email);

  Future<Either<Failure, bool>> checkPhoneAvailability(String phoneNumber);
}
