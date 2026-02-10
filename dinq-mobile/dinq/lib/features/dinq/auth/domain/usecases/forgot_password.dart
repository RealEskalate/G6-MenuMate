import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ForgotPassword implements UseCase<void, ForgotPasswordParams> {
  final AuthRepository authRepository;

  const ForgotPassword(this.authRepository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) async {
    return await authRepository.forgotPassword(email: params.email);
  }
}

class ForgotPasswordParams {
  final String email;

  ForgotPasswordParams({required this.email});
}
