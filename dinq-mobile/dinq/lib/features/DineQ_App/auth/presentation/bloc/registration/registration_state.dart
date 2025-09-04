// lib/features/DineQ_App/auth/presentation/bloc/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:dinq/features/DineQ_App/auth/Domain/entities/customer_registration.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegistered extends AuthState {
  final CustomerRegistration user;

  const AuthRegistered({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthLoggedIn extends AuthState {
  final CustomerRegistration user;

  const AuthLoggedIn({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthLoggedOut extends AuthState {}

class UsernameAvailable extends AuthState {
  final bool isAvailable;

  const UsernameAvailable({required this.isAvailable});

  @override
  List<Object> get props => [isAvailable];
}

class EmailAvailable extends AuthState {
  final bool isAvailable;

  const EmailAvailable({required this.isAvailable});

  @override
  List<Object> get props => [isAvailable];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}