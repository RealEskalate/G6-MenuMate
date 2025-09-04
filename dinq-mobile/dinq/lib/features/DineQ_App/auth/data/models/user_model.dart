// lib/features/DineQ_App/auth/data/models/user_model.dart
import 'package:dinq/features/DineQ_App/auth/Domain/entities/customer_registration.dart';



class UserModel extends CustomerRegistration {
  final String? phoneNumber;

  UserModel({
    required String id,
    required String username,
    required String email,
    required String password,
    required String role,
    required String authprovider,
    String? firstName,
    String? lastName,
    this.phoneNumber,
  }) : super(
         id: id,
         username: username,
         email: email,
         password: password,
         role: role,
         authprovider: authprovider,
         firstName: firstName,
         lastName: lastName,
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
