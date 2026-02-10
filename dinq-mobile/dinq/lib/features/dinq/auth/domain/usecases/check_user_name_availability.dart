import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckUsernameAvailability implements UseCase<bool, CheckUsernameParams> {
  final AuthRepository authRepository;

  const CheckUsernameAvailability(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(CheckUsernameParams params) async {
    return await authRepository.checkUsernameAvailability(params.username);
  }
}

class CheckUsernameParams {
  final String username;
  CheckUsernameParams({required this.username});
}
