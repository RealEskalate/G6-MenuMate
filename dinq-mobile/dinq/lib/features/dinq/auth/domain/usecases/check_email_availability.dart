import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckEmailAvailability implements UseCase<bool, CheckEmailParams> {
  final AuthRepository authRepository;

  const CheckEmailAvailability(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(CheckEmailParams params) async {
    return await authRepository.checkEmailAvailability(params.email);
  }
}

class CheckEmailParams {
  final String email;
  CheckEmailParams({required this.email});
}
