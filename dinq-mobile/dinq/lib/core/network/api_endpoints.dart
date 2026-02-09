// lib/core/network/api_endpoints.dart - TEMPORARY
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // Read BASE_URL at runtime to avoid accessing dotenv during library
  // initialization (which can happen before dotenv is loaded).
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  // Or alternative proxies:
  // static const String baseUrl = 'https://api.allorigins.win/raw?url=https://g6-menumate.onrender.com/api/v1';
  // static const String baseUrl = 'https://cors-anywhere.herokuapp.com/https://g6-menumate.onrender.com/api/v1';

  // Endpoints remain the same but will work through proxy
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String checkUsername = '/auth/check-username';
  static const String checkEmail = '/auth/check-email';
  static const String checkPhone = '/auth/check-phone';
}
