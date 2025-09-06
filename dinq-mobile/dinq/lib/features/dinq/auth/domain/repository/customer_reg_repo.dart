// lib/features/dinq/auth/Domain/repository/auth_repository.dart
import 'package:dinq/features/dinq/auth/domain/entities/customer_registration.dart';
import 'package:dinq/features/dinq/auth/data/models/user_model.dart';
import 'package:file_picker/file_picker.dart';

import '../../../restaurant_management/domain/usecases/restaurant/create_restaurant.dart';
import '../../data/models/resturant_model.dart';

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
    String? role, // Default role
  });


  // reg resturant
  Future<ResturantModel> registerRestaurant({
    required String resturantname,
    required String returantphone,
    required PlatformFile verification_docs,
    PlatformFile? logo_image,
    PlatformFile? cover_image,
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
  // resturant reg
}
