<<<<<<< HEAD
// lib/core/network/api_endpoints.dart - TEMPORARY
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // Temporary CORS proxy solution
  static String baseUrl = dotenv.env['BASE_URL'] ?? 'https://dineq.onrender.com/api/v1';

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
=======
// Centralized API endpoints — grouped by remote data source
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // private base URL
  static String get _baseUrl =>
      dotenv.env['BASE_URL']!;
  // Public root accessor when the raw base URL is required (kept minimal)
  static String get root => _baseUrl;

  // -----------------------------
  // Auth endpoints (features/dinq/auth)
  // -----------------------------
  static String get register => '$_baseUrl/auth/register';
  static String get login => '$_baseUrl/auth/login';
  static String get logout => '$_baseUrl/auth/logout';
  static String get forgotPassword => '$_baseUrl/auth/forgot-password';
  static String get resetPassword => '$_baseUrl/auth/reset-password';
  static String get checkUsername => '$_baseUrl/auth/check-username';
  static String get checkEmail => '$_baseUrl/auth/check-email';
  static String get checkPhone => '$_baseUrl/auth/check-phone';
  static String get googleLogin => '$_baseUrl/auth/google/login';
  static String get googleCallback => '$_baseUrl/auth/google/callback';
  static String get profile => '$_baseUrl/auth/profile';
  static String get changePassword => '$_baseUrl/auth/change-password';
  static String get verifyEmail => '$_baseUrl/auth/verify-email';
  static String get resendOtp => '$_baseUrl/auth/resend-otp';
  static String get verifyOtp => '$_baseUrl/auth/verify-otp';

  // Refresh token endpoint
  static String get refresh => '$_baseUrl/auth/refresh';

  // -----------------------------
  // OCR / Menu endpoints (features/dinq/restaurant_management/menu)
  // -----------------------------
  static String get ocrUpload => '$_baseUrl/ocr/upload';
  static String ocrJob(String jobId) => '$_baseUrl/ocr/$jobId';

  static String get menus => '$_baseUrl/menus';
  static String menusForRestaurant(String slug) => '$_baseUrl/menus/$slug';
  static String publishMenu(String restaurantSlug, String menuId) =>
      '$_baseUrl/menus/$restaurantSlug/publish/$menuId';
  static String menuQr(String restaurantSlug, String menuId) =>
      '$_baseUrl/menus/$restaurantSlug/qrcode/$menuId';
  static String menuById(String menuId) => '$_baseUrl/menus/$menuId';
  static String updateMenu(String restaurantSlug, String menuId) =>
      '$_baseUrl/menus/$restaurantSlug/$menuId';

  // -----------------------------
  // Restaurant endpoints (features/dinq/restaurant_management/restaurant)
  // -----------------------------
  static String get restaurants => '$_baseUrl/restaurants';
  static String restaurantBySlug(String slug) => '$_baseUrl/restaurants/$slug';
  static String restaurantById(String id) => '$_baseUrl/restaurants/$id';

  // -----------------------------
  // Items, Reviews, Images (features/dinq/restaurant_management/review + items)
  // -----------------------------
  static String itemReviews(String itemId) => '$_baseUrl/items/$itemId/reviews';
  static String deleteReview(String reviewId) => '$_baseUrl/reviews/$reviewId';
  static String itemImages(String slug) => '$_baseUrl/items/$slug/images';
>>>>>>> origin/mite-test
}
