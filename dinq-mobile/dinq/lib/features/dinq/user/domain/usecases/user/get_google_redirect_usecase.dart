import '../../repositories/user_repository.dart';

class GetGoogleRedirectUseCase {
  final UserRepository repository;

  GetGoogleRedirectUseCase(this.repository);

  Future<String> call() => repository.getGoogleLoginRedirectUrl();
}
