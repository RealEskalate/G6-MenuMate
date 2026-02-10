import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// ✅ Registration
class RegisterUserEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String authProvider;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  const RegisterUserEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.authProvider,
    required this.role,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props =>
      [username, email, password, authProvider, role, firstName, lastName, phoneNumber];
}

// ✅ Login
class LoginUserEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginUserEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// ✅ Logout
class LogoutUserEvent extends AuthEvent {}

// ✅ Username Availability
class CheckUsernameAvailabilityEvent extends AuthEvent {
  final String username;

  const CheckUsernameAvailabilityEvent({required this.username});

  @override
  List<Object?> get props => [username];
}

// ✅ Email Availability
class CheckEmailAvailabilityEvent extends AuthEvent {
  final String email;

  const CheckEmailAvailabilityEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

// ✅ Phone Availability
class CheckPhoneAvailabilityEvent extends AuthEvent {
  final String phoneNumber;

  const CheckPhoneAvailabilityEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

// ✅ Forgot Password
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

// ✅ Reset Password
class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String token;
  final String newPassword;

  const ResetPasswordEvent({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, token, newPassword];
}
