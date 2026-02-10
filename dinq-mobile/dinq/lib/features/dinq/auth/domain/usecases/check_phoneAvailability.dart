import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckPhoneAvailability implements UseCase<bool, CheckPhoneParams> {
  final AuthRepository authRepository;

  const CheckPhoneAvailability(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(CheckPhoneParams params) async {
    return await authRepository.checkPhoneAvailability(params.phoneNumber);
  }
}

class CheckPhoneParams {
  final String phoneNumber;
  CheckPhoneParams({required this.phoneNumber});
}
