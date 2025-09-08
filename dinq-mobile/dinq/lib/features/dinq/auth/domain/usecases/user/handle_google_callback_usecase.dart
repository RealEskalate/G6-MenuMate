import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

class HandleGoogleCallbackUseCase {
  final UserRepository repository;

  HandleGoogleCallbackUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String code,
    String? state,
  }) {
    return repository.handleGoogleOAuthCallback(code: code, state: state);
  }
}
