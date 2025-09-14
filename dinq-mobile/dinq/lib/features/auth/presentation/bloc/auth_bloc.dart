import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/user_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUserUseCase registerUser;
  final LoginUserUseCase loginUser;
  final LogoutUseCase logout;
  final GetCachedUserUseCase getCachedUser;
  final UserRepository userRepository;

  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.logout,
    required this.getCachedUser,
    required this.userRepository,
  }) : super(AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCachedUser.call();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUser.call(
      identifier: event.identifier,
      password: event.password,
    );
    final future = result.fold(
      (failure) => Future(() => emit(AuthError(failure.message))),
      (user) => userRepository.cacheUserJson(user).then((_) => emit(Authenticated(user))),
    );
    await future;
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerUser.call(
        username: event.username,
        email: event.email,
        password: event.password,
        authProvider: event.authProvider,
        role: event.role ?? 'USER',
        firstName: event.firstName,
        lastName: event.lastName,
      );
    final future = result.fold(
      (failure) => Future(() => emit(AuthError(failure.message))),
      (user) => userRepository.cacheUserJson(user).then((_) => emit(Authenticated(user))),
    );
    await future;
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await logout.call();
    await userRepository.clearCachedUser();
    emit(Unauthenticated());
  }
}
