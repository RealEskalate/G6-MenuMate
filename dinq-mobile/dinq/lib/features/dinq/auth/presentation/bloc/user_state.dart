import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserRegistered extends UserState {
  final User user;

  const UserRegistered(this.user);

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserLoggedIn extends UserState {
  final User user;

  const UserLoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class UserLoggedOut extends UserState {
  const UserLoggedOut();
}

class AuthChecked extends UserState {
  final User? user;

  const AuthChecked(this.user);

  @override
  List<Object?> get props => [user];
}

class OtpVerified extends UserState {
  const OtpVerified();
}

class OtpSent extends UserState {
  const OtpSent();
}

class EmailVerified extends UserState {
  const EmailVerified();
}

class PasswordResetDone extends UserState {
  const PasswordResetDone();
}

class ProfileUpdated extends UserState {
  const ProfileUpdated();
}

class GoogleRedirectUrl extends UserState {
  final String url;

  const GoogleRedirectUrl(this.url);

  @override
  List<Object?> get props => [url];
}

class GoogleAuthHandled extends UserState {
  const GoogleAuthHandled();
}
