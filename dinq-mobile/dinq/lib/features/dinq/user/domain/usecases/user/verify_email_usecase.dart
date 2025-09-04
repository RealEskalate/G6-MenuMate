import '../../repositories/user_repository.dart';

class VerifyEmailUseCase {
  final UserRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<void> call({required String otp}) => repository.verifyEmail(otp: otp);
}
