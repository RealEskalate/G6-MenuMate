import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/token_manager.dart';
import '../../domain/usecases/user/change_password_usecase.dart';
import '../../domain/usecases/user/forgot_password_usecase.dart';
import '../../domain/usecases/user/get_google_redirect_usecase.dart';
import '../../domain/usecases/user/handle_google_callback_usecase.dart';
import '../../domain/usecases/user/login_user_usecase.dart';
import '../../domain/usecases/user/logout_usecase.dart';
import '../../domain/usecases/user/register_user_usecase.dart';
import '../../domain/usecases/user/resend_otp_usecase.dart';
import '../../domain/usecases/user/reset_password_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../../domain/usecases/user/verify_email_usecase.dart';
import '../../domain/usecases/user/verify_otp_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final RegisterUserUseCase registerUser;
  final LoginUserUseCase loginUser;
  final VerifyOtpUseCase verifyOtp;
  final ResendOtpUseCase resendOtp;
  final VerifyEmailUseCase verifyEmail;
  final ForgotPasswordUseCase forgotPassword;
  final ResetPasswordUseCase resetPassword;
  final ChangePasswordUseCase changePassword;
  final UpdateProfileUseCase updateProfile;
  final GetGoogleRedirectUseCase getGoogleRedirect;
  final HandleGoogleCallbackUseCase handleGoogleCallback;
  final LogoutUseCase logout;

  UserBloc({
    required this.registerUser,
    required this.loginUser,
    required this.verifyOtp,
    required this.resendOtp,
    required this.verifyEmail,
    required this.forgotPassword,
    required this.resetPassword,
    required this.changePassword,
    required this.updateProfile,
    required this.getGoogleRedirect,
    required this.handleGoogleCallback,
    required this.logout,
  }) : super(const UserInitial()) {
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LogoutUserEvent>(_onLogoutUser);
    on<CheckAuthEvent>(_onCheckAuth);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ChangePasswordEvent>(_onChangePassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<GetGoogleRedirectEvent>(_onGetGoogleRedirect);
    on<HandleGoogleCallbackEvent>(_onHandleGoogleCallback);
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await registerUser.call(
      username: event.username,
      email: event.email,
      password: event.password,
      authProvider: event.authProvider,
      firstName: event.firstName,
      lastName: event.lastName,
      role: event.role,
    );
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserRegistered(user)),
    );
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await loginUser.call(
      identifier: event.identifier,
      password: event.password,
    );
    result.fold((failure) => emit(UserError(failure.message)), (user) {
      emit(UserLoggedIn(user));
    });
  }

  Future<void> _onLogoutUser(
    LogoutUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await logout.call();
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) async {
        // attempt to clear cached tokens locally; ignore errors
        try {
          await TokenManager.clearTokensStatic();
        } catch (_) {}
        emit(const UserLoggedOut());
      },
    );
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final tokens = await TokenManager.getCachedTokensStatic();
      if (tokens != null && tokens.isNotEmpty) {
        // TODO: Validate token with backend or get user profile
        // For now, just emit AuthChecked with null user
        // In a real app, you'd call a getProfile use case
        emit(const AuthChecked(null));
      } else {
        emit(const AuthChecked(null));
      }
    } catch (e) {
      emit(const AuthChecked(null));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result =
        await verifyOtp.call(otp: event.otp, identifier: event.identifier);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const OtpVerified()));
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await resendOtp.call(email: event.identifier);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const OtpSent()));
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await verifyEmail.call(otp: event.token);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const EmailVerified()));
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await forgotPassword.call(email: event.email);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const OtpSent()));
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await resetPassword.call(
        token: event.token, newPassword: event.newPassword);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const PasswordResetDone()));
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await changePassword.call(
        currentPassword: event.currentPassword, newPassword: event.newPassword);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const PasswordResetDone()));
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await updateProfile.call(updates: event.updates);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const ProfileUpdated()));
  }

  Future<void> _onGetGoogleRedirect(
    GetGoogleRedirectEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await getGoogleRedirect.call();
    result.fold((failure) => emit(UserError(failure.message)),
        (url) => emit(GoogleRedirectUrl(url)));
  }

  Future<void> _onHandleGoogleCallback(
    HandleGoogleCallbackEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await handleGoogleCallback.call(code: event.code);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const GoogleAuthHandled()));
  }
}
