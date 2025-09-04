import '../../repositories/user_repository.dart';

class ResendOtpUseCase {
  final UserRepository repository;

  ResendOtpUseCase(this.repository);

  Future<void> call({required String email}) =>
      repository.resendOtp(email: email);
}
