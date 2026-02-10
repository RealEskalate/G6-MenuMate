
import '../models/user_model.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel userModel; // <-- use your UserModel here

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userModel,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userModel: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': userModel.toJson(),
    };
  }
}
