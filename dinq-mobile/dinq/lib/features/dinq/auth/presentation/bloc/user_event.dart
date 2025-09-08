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

class LoginUserEvent extends UserEvent {
  final String identifier;
  final String password;

  const LoginUserEvent({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier];
}

class LogoutUserEvent extends UserEvent {}

class CheckAuthEvent extends UserEvent {}

class VerifyOtpEvent extends UserEvent {
  final String otp;
  final String identifier;

  const VerifyOtpEvent({required this.otp, required this.identifier});

  @override
  List<Object?> get props => [otp, identifier];
}

class ResendOtpEvent extends UserEvent {
  final String identifier;

  const ResendOtpEvent({required this.identifier});

  @override
  List<Object?> get props => [identifier];
}

class VerifyEmailEvent extends UserEvent {
  final String token;

  const VerifyEmailEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

class ForgotPasswordEvent extends UserEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends UserEvent {
  final String token;
  final String newPassword;

  const ResetPasswordEvent({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token];
}

class ChangePasswordEvent extends UserEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent(
      {required this.currentPassword, required this.newPassword});

  @override
  List<Object?> get props => [currentPassword];
}

class UpdateProfileEvent extends UserEvent {
  final Map<String, dynamic> updates;

  const UpdateProfileEvent({required this.updates});

  @override
  List<Object?> get props => [updates];
}

class GetGoogleRedirectEvent extends UserEvent {}

class HandleGoogleCallbackEvent extends UserEvent {
  final String code;

  const HandleGoogleCallbackEvent({required this.code});

  @override
  List<Object?> get props => [code];
}
