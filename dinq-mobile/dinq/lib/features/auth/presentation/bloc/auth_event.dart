import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String identifier;
  final String password;

  LoginEvent({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String authProvider;
  final String? firstName;
  final String? lastName;
  final String? role;

  RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.authProvider,
    this.firstName,
    this.lastName,
    this.role,
  });

  @override
  List<Object?> get props => [username, email, authProvider];
}

class LogoutEvent extends AuthEvent {}
