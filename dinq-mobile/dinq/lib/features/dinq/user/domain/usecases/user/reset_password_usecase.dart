import '../../repositories/user_repository.dart';

class ResetPasswordUseCase {
  final UserRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call({required String token, required String newPassword}) {
    return repository.resetPassword(token: token, newPassword: newPassword);
  }
}
