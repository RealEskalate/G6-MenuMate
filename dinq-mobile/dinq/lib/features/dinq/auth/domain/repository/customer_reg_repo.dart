// lib/features/dinq/auth/Domain/repository/auth_repository.dart
import '../entities/customer_registration.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  // Registration
  Future<UserModel> registerUser({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String role = 'CUSTOMER', // Default role
  });

  // Authentication
  Future<UserModel> login({
    required String email, // Can be username, email, or phone
    required String password,
  });


  Future<void> logout();

  // Password Management
  Future<void> forgotPassword({
    required String email,
  });

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  // Availability Checks
  Future<bool> checkUsernameAvailability(String username);
  Future<bool> checkEmailAvailability(String email);
  Future<bool> checkPhoneAvailability(String phoneNumber);
}