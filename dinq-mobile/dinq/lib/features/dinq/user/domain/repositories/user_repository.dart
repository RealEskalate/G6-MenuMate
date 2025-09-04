abstract class UserRepository {
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    String? firstName,
    String? lastName,
    String? role,
  });

  Future<Map<String, dynamic>> loginUser({
    required String identifier,
    required String password,
  });

  Future<String> getGoogleLoginRedirectUrl();

  Future<Map<String, dynamic>> handleGoogleOAuthCallback({
    required String code,
    String? state,
  });

  Future<void> forgotPassword({required String email});

  Future<void> logout();

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> verifyEmail({required String otp});

  Future<void> resendOtp({required String email});

  Future<void> verifyOtp({required String otp, required String identifier});
}
