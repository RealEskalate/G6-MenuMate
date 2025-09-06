import 'package:equatable/equatable.dart';

class CustomerRegistration extends Equatable {
  final String id;
  final String username;
  final String email;
  final String password;
  final String role;
  final String authprovider;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  const CustomerRegistration({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.authprovider,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });
  @override
  List<Object> get props => [
    id,
        username,
        email,
        password,
        role,
        authprovider,
        phoneNumber ?? '',
        firstName ?? '',
        lastName ?? '',
  ];
}
