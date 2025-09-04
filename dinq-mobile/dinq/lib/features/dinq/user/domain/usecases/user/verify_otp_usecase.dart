import '../../repositories/user_repository.dart';

class VerifyOtpUseCase {
  final UserRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<void> call({required String otp, required String identifier}) =>
      repository.verifyOtp(otp: otp, identifier: identifier);
}
