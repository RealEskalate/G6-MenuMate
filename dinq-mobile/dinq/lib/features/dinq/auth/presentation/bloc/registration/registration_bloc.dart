// lib/features/DineQ_App/auth/presentation/bloc/auth/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/check_email_availability.dart';
import '../../../domain/usecases/check_phoneAvailability.dart';
import '../../../domain/usecases/check_user_name_availability.dart';
import '../../../domain/usecases/forgot_password.dart';
import '../../../domain/usecases/reset_password.dart';
import '../../../domain/usecases/user_log_out.dart';
import '../../../domain/usecases/user_sign_in.dart';
import '../../../domain/usecases/user_sign_up.dart';
import 'registration_event.dart';
import 'registration_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp userSignUp;
  final UserSignIn userSignIn;
  final UserLogout userLogout;
  final CheckUsernameAvailability checkUsernameAvailability;
  final CheckEmailAvailability checkEmailAvailability;
  final CheckPhoneAvailability checkPhoneAvailability;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;

  AuthBloc({
    required this.userSignUp,
    required this.userSignIn,
    required this.userLogout,
    required this.checkUsernameAvailability,
    required this.checkEmailAvailability,
    required this.checkPhoneAvailability,
    required this.forgotPassword,
    required this.resetPassword,
  }) : super(AuthInitial()) {
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LogoutUserEvent>(_onLogoutUser);
    on<CheckUsernameAvailabilityEvent>(_onCheckUsernameAvailability);
    on<CheckEmailAvailabilityEvent>(_onCheckEmailAvailability);
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final params = UserSignUpParams(
      username: event.username,
      email: event.email,
      password: event.password,
      authProvider: event.authProvider,
      role: event.role,
      firstName: event.firstName,
      lastName: event.lastName,
      phoneNumber: event.phoneNumber,
    );

    final result = await userSignUp(params);

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthRegistered(user: user)),
    );
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final params = UserSignInParams(
      email: event.email,
      password: event.password,
    );

    final result = await userSignIn(params);

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthLoggedIn(user: user)),
    );
  }

  Future<void> _onLogoutUser(
    LogoutUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await userLogout(NoParams());

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(AuthLoggedOut()),
    );
  }

  Future<void> _onCheckUsernameAvailability(
    CheckUsernameAvailabilityEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkUsernameAvailability(
      CheckUsernameParams(username: event.username),
    );

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (isAvailable) => emit(UsernameAvailable(isAvailable: isAvailable)),
    );
  }

  Future<void> _onCheckEmailAvailability(
    CheckEmailAvailabilityEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkEmailAvailability(
      CheckEmailParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (isAvailable) => emit(EmailAvailable(isAvailable: isAvailable)),
    );
  }

  // Convert Failure into user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    return 'Unexpected error occurred';
  }
}
