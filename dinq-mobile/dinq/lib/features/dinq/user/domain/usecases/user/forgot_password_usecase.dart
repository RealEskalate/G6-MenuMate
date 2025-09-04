import '../../repositories/user_repository.dart';

class ForgotPasswordUseCase {
  final UserRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> call({required String email}) =>
      repository.forgotPassword(email: email);
}
