
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
    print("reached this point");

    return AuthResponse(
      accessToken: json['tokens']['access_token'] as String,
      refreshToken: json['tokens']['refresh_token'] as String,

      userModel: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': userModel.toJson(),
    };
  }
}
