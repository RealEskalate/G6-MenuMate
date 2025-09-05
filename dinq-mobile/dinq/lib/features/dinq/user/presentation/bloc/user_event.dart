import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class RegisterUserEvent extends UserEvent {
  final String username;
  final String email;
  final String password;
  final String authProvider;
  final String? firstName;
  final String? lastName;
  final String? role;

  const RegisterUserEvent({
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
