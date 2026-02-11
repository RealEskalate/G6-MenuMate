import 'package:dinq/features/dinq/auth/domain/entities/customer_registration.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String username,
    required String email,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) : super(
          id: id,
          username: username,
          email: email,
          role: role,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("reached this point");
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'] ?? '',
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
    };
  }
}
