// lib/features/dinq/auth/domain/usecases/register_user_usecase.dart
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../entities/customer_registration.dart';
import '../repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';


// class RegisterUserUseCase {
//   final AuthRepository repository;

//   RegisterUserUseCase(this.repository);

//   Future<UserModel> call({
//     required String username,
//     required String email,
//     required String password,
//     required String authProvider,
//     String? firstName,
//     String? lastName,
//     String? phoneNumber,
//   }) async {
//     // Business logic validation can go here
//     final user = await repository.registerUser(
//       username: username,
//       email: email,
//       password: password,
//       authProvider: authProvider,
//       firstName: firstName,
//       lastName: lastName,
//       phoneNumber: phoneNumber,
//     );
//     return user; // UserModel is a CustomerRegistration
//   }
// }

class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);
  @override
   Future<Either<Failure, User>> call(UserSignUpParams params)async {
      return await authRepository.register(
        firstName: params.firstName,
        lastName: params.lastName,
        username: params.username,
        password: params.password,
        authProvider: params.authProvider,
        role: params.role,
        phoneNumber: params.phoneNumber,
        email: params.email
      );

  }

}

class UserSignUpParams{
    String username;
    String email;
    String password;
    String authProvider;
    String role;
    String? firstName;
    String? lastName;
    String? phoneNumber;
  UserSignUpParams({
    required this.username,
    required this.email,
    required this.password,
    required this.authProvider,
    required this.role,
    this.firstName,
    this.lastName,
    this.phoneNumber,

    });
}