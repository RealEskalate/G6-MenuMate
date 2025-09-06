// lib/core/network/api_endpoints.dart - TEMPORARY
class ApiEndpoints {
  // Temporary CORS proxy solution
  static const String baseUrl = 'https://g6-menumate.onrender.com/api/v1';

  // Or alternative proxies:
  // static const String baseUrl = 'https://api.allorigins.win/raw?url=https://g6-menumate.onrender.com/api/v1';
  // static const String baseUrl = 'https://cors-anywhere.herokuapp.com/https://g6-menumate.onrender.com/api/v1';

  // Endpoints remain the same but will work through proxy
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String resturantdetails = '/restaurants';
  static const String fileupload = '/uploads/image';
  static const String checkUsername = '/auth/check-username';
  static const String checkEmail = '/auth/check-email';
  static const String checkPhone = '/auth/check-phone';
}
