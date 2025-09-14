import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/delete_favorite_id.dart';
import '../../domain/usecases/user_usecases.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final RegisterUserUseCase registerUser;
  final LoginUserUseCase loginUser;
  final VerifyOtpUseCase verifyOtp;
  final ResendOtpUseCase resendOtp;
  final VerifyEmailUseCase verifyEmail;
  final DeleteFavoriteId deleteFavoriteId;
  final ForgotPasswordUseCase forgotPassword;
  final ResetPasswordUseCase resetPassword;
  final ChangePasswordUseCase changePassword;
  final UpdateProfileUseCase updateProfile;
  final GetGoogleRedirectUseCase getGoogleRedirect;
  final HandleGoogleCallbackUseCase handleGoogleCallback;
  final LogoutUseCase logout;
  final GetCachedUserUseCase getCachedUser;
  final SaveFavoriteRestaurantIdsUseCase saveFavoriteRestaurantIds;
  final GetFavoriteRestaurantIdsUseCase getFavoriteRestaurantIds;
  final ClearFavoritesUseCase clearFavorites;
  final UserRepository userRepository;

  UserBloc({
    required this.registerUser,
    required this.loginUser,
    required this.verifyOtp,
    required this.resendOtp,
    required this.verifyEmail,
    required this.deleteFavoriteId,
    required this.forgotPassword,
    required this.resetPassword,
    required this.changePassword,
    required this.updateProfile,
    required this.getGoogleRedirect,
    required this.handleGoogleCallback,
    required this.logout,
    required this.getCachedUser,
    required this.saveFavoriteRestaurantIds,
    required this.getFavoriteRestaurantIds,
    required this.clearFavorites,
    required this.userRepository,
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
    on<SaveFavoriteRestaurantIdsEvent>(_onSaveFavoriteRestaurantIds);
    on<GetFavoriteRestaurantsEvent>(_onGetFavoriteRestaurants);
    on<ClearFavoritesEvent>(_onClearFavorites);
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
    final future = result.fold(
      (failure) => Future(() => emit(UserError(failure.message))),
      (user) => userRepository
          .cacheUserJson(user)
          .then((_) => emit(UserRegistered(user))),
    );
    await future;
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<UserState> emit,
  ) async {
    print('DEBUG: _onLoginUser started');
    emit(const UserLoading());
    final result = await loginUser.call(
      identifier: event.identifier,
      password: event.password,
    );
    print('DEBUG: loginUser.call completed');
    final future = result.fold(
      (failure) => Future(() {
        print('DEBUG: Login failed: ${failure.message}');
        emit(UserError(failure.message));
      }),
      (user) => userRepository.cacheUserJson(user).then((_) {
        print('DEBUG: User cached, emitting UserLoggedIn');
        emit(UserLoggedIn(user));
        print('DEBUG: UserLoggedIn emitted');
      }),
    );
    await future;
    print('DEBUG: _onLoginUser completed');
  }

  Future<void> _onLogoutUser(
    LogoutUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await logout.call();
    final future = result.fold(
      (failure) => Future(() => emit(UserError(failure.message))),
      (_) => userRepository
          .clearCachedUser()
          .then((_) => emit(const UserLoggedOut())),
    );
    await future;
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<UserState> emit,
  ) async {
    final result = await getCachedUser.call();
    result.fold(
      (failure) => emit(const AuthChecked(null)),
      (user) => emit(AuthChecked(user)),
    );
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

  Future<void> _onSaveFavoriteRestaurantIds(
    SaveFavoriteRestaurantIdsEvent event,
    Emitter<UserState> emit,
  ) async {
    final result = await saveFavoriteRestaurantIds.call(event.id);
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const FavoriteSaved()));
  }

  Future<void> _onGetFavoriteRestaurants(
    GetFavoriteRestaurantsEvent event,
    Emitter<UserState> emit,
  ) async {
    final result = await getFavoriteRestaurantIds.call();
    result.fold((failure) => emit(UserError(failure.message)),
        (ids) => emit(FavoritesLoaded(ids)));
  }

  Future<void> _onClearFavorites(
    ClearFavoritesEvent event,
    Emitter<UserState> emit,
  ) async {
    final result = await clearFavorites.call();
    result.fold((failure) => emit(UserError(failure.message)),
        (_) => emit(const FavoritesCleared()));
  }
}
