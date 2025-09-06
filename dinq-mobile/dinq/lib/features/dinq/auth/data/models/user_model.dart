// lib/features/DineQ_App/auth/data/models/user_model.dart
import '../../domain/entities/customer_registration.dart';



class UserModel extends CustomerRegistration {
  @override
  final String? phoneNumber;

  UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.password,
    required super.role,
    required super.authprovider,
    super.firstName,
    super.lastName,
    this.phoneNumber,
  }) : super(
         phoneNumber: phoneNumber,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      authprovider: json['auth_provider'] ?? 'EMAIL',
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'password': password,
      'auth_provider': authprovider,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
    };
  }
}
