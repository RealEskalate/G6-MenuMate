// lib/features/DineQ_App/auth/domain/usecases/register_user_usecase.dart
import 'package:dinq/features/DineQ_App/auth/Domain/entities/customer_registration.dart';
import 'package:dinq/features/DineQ_App/auth/Domain/repository/customer_reg_repo.dart';



class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<CustomerRegistration> call({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    // Business logic validation can go here
    return await repository.registerUser(
      username: username,
      email: email,
      password: password,
      authProvider: authProvider,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
  }
}