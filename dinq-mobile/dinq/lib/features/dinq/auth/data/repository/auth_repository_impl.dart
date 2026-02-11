import 'package:dinq/core/network/token_manager.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> register({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) {
    return TaskEither<Failure, UserModel>(() async {
      final result = await remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        authProvider: authProvider,
        role: role,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      return result.map((authResponse) {
        // Save tokens as a side effect
        TokenManager.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );
        // Return only the user
        return authResponse.userModel;
      });
      
    }).run();
  }

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) {
    return TaskEither<Failure, UserModel>(() async {
      final result = await remoteDataSource.login(email: email, password: password);

      return result.map((authResponse) {
        TokenManager.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );
        return authResponse.userModel; // return just the user
      });
    }).run();
  }

  @override
  Future<Either<Failure, void>> logout() {
    return TaskEither<Failure, void>(() async {
      final result = await remoteDataSource.logout();

      return result.map((_) {
        TokenManager.clearTokens();
        return null;
      });
    }).run();
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) {
    return remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) {
    return remoteDataSource.resetPassword(
      email: email,
      token: token,
      newPassword: newPassword,
    );
  }

  @override
  Future<Either<Failure, bool>> checkUsernameAvailability(String username) {
    return remoteDataSource.checkUsernameAvailability(username);
  }

  @override
  Future<Either<Failure, bool>> checkEmailAvailability(String email) {
    return remoteDataSource.checkEmailAvailability(email);
  }

  @override
  Future<Either<Failure, bool>> checkPhoneAvailability(String phoneNumber) {
    return remoteDataSource.checkPhoneAvailability(phoneNumber);
  }
}
