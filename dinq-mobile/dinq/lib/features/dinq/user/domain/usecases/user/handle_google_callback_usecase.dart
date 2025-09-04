import '../../repositories/user_repository.dart';

class HandleGoogleCallbackUseCase {
  final UserRepository repository;

  HandleGoogleCallbackUseCase(this.repository);

  Future<Map<String, dynamic>> call({required String code, String? state}) {
    return repository.handleGoogleOAuthCallback(code: code, state: state);
  }
}
