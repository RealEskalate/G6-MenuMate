import 'package:equatable/equatable.dart';
import '../../../domain/entities/customer_registration.dart';


abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

// Initial
class AuthInitial extends AuthState {}

// Loading
class AuthLoading extends AuthState {}

// ✅ Registration success
class AuthRegistered extends AuthState {
  final User user;
  const AuthRegistered({required this.user});

  @override
  List<Object?> get props => [user];
}

// ✅ Login success
class AuthLoggedIn extends AuthState {
  final User user;
  const AuthLoggedIn({required this.user});

  @override
  List<Object?> get props => [user];
}

// ✅ Logout success
class AuthLoggedOut extends AuthState {}

// ✅ Username availability
class UsernameAvailable extends AuthState {
  final bool isAvailable;
  const UsernameAvailable({required this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}

// ✅ Email availability
class EmailAvailable extends AuthState {
  final bool isAvailable;
  const EmailAvailable({required this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}

// ✅ Phone availability
class PhoneAvailable extends AuthState {
  final bool isAvailable;
  const PhoneAvailable({required this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}

// ✅ Forgot password success (no data needed)
class ForgotPasswordSent extends AuthState {}

// ✅ Reset password success (no data needed)
class ResetPasswordSuccess extends AuthState {}

// Error
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
