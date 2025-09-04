import 'dart:convert';
import 'package:http/http.dart' as http;
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? responseData;

  ApiException({
    required this.message,
    required this.statusCode,
    this.responseData,
  });

  factory ApiException.fromResponse(http.Response response) {
    try {
      final responseData = json.decode(response.body);
      return ApiException(
        message: responseData['message'] ?? 'API Error',
        statusCode: response.statusCode,
        responseData: responseData,
      );
    } catch (_) {
      return ApiException(
        message: 'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}