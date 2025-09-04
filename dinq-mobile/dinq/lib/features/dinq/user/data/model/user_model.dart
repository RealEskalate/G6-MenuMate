import 'dart:convert';

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    required super.status,
    required super.authProvider,
    required super.isVerified,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    String parseString(String a, String b) =>
        (data[a] ?? data[b] ?? '') as String;

    bool parseBool(String a, String b) => (data[a] ?? data[b] ?? false) as bool;

    DateTime parseDate(String a, String b) {
      final s = data[a] ?? data[b];
      if (s == null) return DateTime.now();
      return DateTime.tryParse(s.toString()) ?? DateTime.now();
    }

    return UserModel(
      id: parseString('id', 'id'),
      username: parseString('username', 'username'),
      email: parseString('email', 'email'),
      firstName: parseString('first_name', 'firstName'),
      lastName: parseString('last_name', 'lastName'),
      role: parseString('role', 'role'),
      status: parseString('status', 'status'),
      authProvider: parseString('auth_provider', 'authProvider'),
      isVerified: parseBool('is_verified', 'isVerified'),
      createdAt: parseDate('created_at', 'createdAt'),
      updatedAt: parseDate('updated_at', 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': role,
    'status': status,
    'auth_provider': authProvider,
    'is_verified': isVerified,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory UserModel.fromJson(String data) {
    return UserModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? status,
    String? authProvider,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      status: status ?? this.status,
      authProvider: authProvider ?? this.authProvider,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool get stringify => true;

  User toEntity() => this;

  factory UserModel.fromEntity(User entity) => UserModel(
    id: entity.id,
    username: entity.username,
    email: entity.email,
    firstName: entity.firstName,
    lastName: entity.lastName,
    role: entity.role,
    status: entity.status,
    authProvider: entity.authProvider,
    isVerified: entity.isVerified,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
