import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ResetPassword implements UseCase<void, ResetPasswordParams> {
  final AuthRepository authRepository;

  const ResetPassword(this.authRepository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await authRepository.resetPassword(
      email: params.email,
      token: params.token,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams {
  final String email;
  final String token;
  final String newPassword;

  ResetPasswordParams({
    required this.email,
    required this.token,
    required this.newPassword,
  });
}
