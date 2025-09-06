// lib/features/dinq/auth/domain/usecases/register_user_usecase.dart
import 'package:dinq/features/dinq/auth/Domain/entities/customer_registration.dart';
import 'package:dinq/features/dinq/auth/Domain/repository/customer_reg_repo.dart';
import 'package:dinq/features/dinq/auth/data/models/user_model.dart';



class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<UserModel> call({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    // Business logic validation can go here
    final user = await repository.registerUser(
      username: username,
      email: email,
      password: password,
      authProvider: authProvider,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
    return user; // UserModel is a CustomerRegistration
  }

}