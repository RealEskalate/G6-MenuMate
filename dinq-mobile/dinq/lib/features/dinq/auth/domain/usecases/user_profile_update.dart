import 'dart:io';

import 'package:fpdart/fpdart.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../entities/customer_registration.dart';
import '../repository/auth_repository.dart';

class UserProfileUpdate implements UseCase<User, UserProfileUpdateParams> {
  final AuthRepository authRepository;

  const UserProfileUpdate(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserProfileUpdateParams params) async {
    return await authRepository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      image: params.image
    );
  }
}

class UserProfileUpdateParams {
  final String firstName;
  final String lastName;
  final File? image;

  UserProfileUpdateParams(
      {required this.firstName, required this.lastName, this.image});
}
