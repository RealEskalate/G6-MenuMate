import '../../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Map<String, dynamic>> call(Map<String, dynamic> updates) =>
      repository.updateProfile(updates);
}
