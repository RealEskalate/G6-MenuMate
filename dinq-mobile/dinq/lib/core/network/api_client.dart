import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exceptions.dart';
import 'token_manager.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;

  ApiClient({required this.baseUrl, http.Client? client}) 
    : client = client ?? http.Client();

 // Update your ApiClient with detailed debugging
Future<Map<String, dynamic>> get(
  String endpoint, {
  Map<String, String>? headers,
  Map<String, dynamic>? queryParameters,
}) async {
  try {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters,
    );

    final requestHeaders = await _withDefaultHeaders(headers);

    print('🌐 GET Request:');
    print('📋 URL: $uri');
    print('📋 Headers: $requestHeaders');
    print('📋 Query Params: $queryParameters');

    final response = await client.get(uri, headers: requestHeaders);

    print('📨 GET Response:');
    print('📊 Status: ${response.statusCode}');
    print('📊 Headers: ${response.headers}');
    print('📊 Body: ${response.body}');

    return _handleResponse(response);
  } catch (e) {
    print('❌ GET Error: $e');
    throw _handleError(e);
  }
}
 // lib/core/network/api_client.dart - UPDATED
Future<Map<String, dynamic>> post(
  String endpoint, {
  Map<String, String>? headers,
  dynamic body,
}) async {
  try {
    final uri = Uri.parse('$baseUrl$endpoint');

    final requestHeaders = await _withDefaultHeaders(headers);

    // DEBUG: Print the request details
    print('🌐 API POST Request:');
    print('URL: $uri');
    print('Headers: $requestHeaders');
    print('Body: $body');

    final response = await client.post(
      uri,
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );

    // DEBUG: Print the response
    print('📨 API Response:');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    return _handleResponse(response);
  } catch (e) {
    print('❌ API POST Error: $e');
    throw _handleError(e);
  }
}
  Future<Map<String, String>> _withDefaultHeaders(Map<String, String>? headers) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add Authorization header if token exists
    final authHeaders = await TokenManager.getAuthHeaders();
    if (authHeaders != null) {
      defaultHeaders.addAll(authHeaders);
    }

    return {...defaultHeaders, ...?headers};
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) {
        return {};
      }
      return json.decode(responseBody);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  Never _handleError(dynamic error) {
    if (error is http.ClientException) {
      throw ApiException(
        message: 'Network error: ${error.message}',
        statusCode: 0,
      );
    } else if (error is ApiException) {
      throw error;
    } else {
      throw ApiException(
        message: 'Unexpected error: $error',
        statusCode: 0,
      );
    }
  }

  void close() {
    client.close();
  }
}