// lib/features/DineQ_App/auth/presentation/bloc/auth/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dinq/features/DineQ_App/auth/Domain/entities/customer_registration.dart';
import 'package:dinq/features/DineQ_App/auth/Domain/repository/Customer_reg_repo.dart';
import 'package:dinq/features/DineQ_App/auth/presentation/bloc/registration/registration_event.dart';
import 'package:dinq/features/DineQ_App/auth/presentation/bloc/registration/registration_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
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
    try {
      final user = await _authRepository.registerUser(
        username: event.username,
        email: event.email,
        password: event.password,
        authProvider: event.authProvider,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
      );
      emit(AuthRegistered(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthLoggedIn(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutUser(
    LogoutUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCheckUsernameAvailability(
    CheckUsernameAvailabilityEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAvailable = await _authRepository.checkUsernameAvailability(
        event.username,
      );
      emit(UsernameAvailable(isAvailable: isAvailable));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCheckEmailAvailability(
    CheckEmailAvailabilityEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAvailable = await _authRepository.checkEmailAvailability(
        event.email,
      );
      emit(EmailAvailable(isAvailable: isAvailable));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}