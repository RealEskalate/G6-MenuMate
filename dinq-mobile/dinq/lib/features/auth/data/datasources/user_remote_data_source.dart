abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String authProvider,
    required String role,
    String? firstName,
    String? lastName,
  });
  Future<Map<String, dynamic>> loginUser(String identifier, String password);
  Future<String> getGoogleLoginRedirectUrl();
  Future<Map<String, dynamic>> handleGoogleCallback(String code, String? state);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Future<void> resetPassword(String token, String newPassword);
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> verifyEmail(String otp);
  Future<void> resendOtp(String email);
  Future<void> verifyOtp(String otp, String identifier);
}
