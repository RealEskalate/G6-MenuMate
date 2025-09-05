// lib/features/DineQ_App/auth/presentation/bloc/auth/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RegisterUserEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String authProvider;
  final String? role;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  const RegisterUserEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.authProvider,
    this.role,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  @override
  List<Object> get props => [
        username,
        email,
        password,
        authProvider,
        role ?? '',
        firstName ?? '',
        lastName ?? '',
        phoneNumber ?? '',
      ];
}

class LoginUserEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginUserEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class LogoutUserEvent extends AuthEvent {}

class CheckUsernameAvailabilityEvent extends AuthEvent {
  final String username;

  const CheckUsernameAvailabilityEvent({required this.username});

  @override
  List<Object> get props => [username];
}

class CheckEmailAvailabilityEvent extends AuthEvent {
  final String email;

  const CheckEmailAvailabilityEvent({required this.email});

  @override
  List<Object> get props => [email];
}