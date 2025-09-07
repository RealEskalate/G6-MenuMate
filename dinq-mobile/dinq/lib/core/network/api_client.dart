import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

    final response = await client.get(uri, headers: requestHeaders);

    return _handleResponse(response);
  } catch (e) {
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

    final response = await client.post(
      uri,
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );

    return _handleResponse(response);
  } catch (e) {
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

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? headers,
    String fieldName = 'menuImage',
  }) async {
    try {
      print('🔄 Starting file upload to: $baseUrl$endpoint');

      // Validate file size (5MB limit)
      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5MB in bytes
      if (fileSize > maxSize) {
        throw ApiException(
          message: 'File size exceeds 5MB limit. Current size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB',
          statusCode: 413,
        );
      }
      print('✅ File size validation passed: ${(fileSize / 1024).toStringAsFixed(2)}KB');

      // Validate file type (should be image)
      final fileName = file.path.split('/').last.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
      final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));

      if (!hasValidExtension) {
        throw ApiException(
          message: 'Invalid file format. Supported formats: JPG, PNG, GIF, BMP, WebP',
          statusCode: 400,
        );
      }
      print('✅ File format validation passed: $fileName');

      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 Upload URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      final authHeaders = await TokenManager.getAuthHeaders();
      if (authHeaders != null) {
        request.headers.addAll(authHeaders);
        print('🔑 Authorization header added: ${authHeaders['Authorization']?.substring(0, 20)}...');
      } else {
        print('❌ No authorization headers found!');
      }

      // Remove Content-Type from headers as it will be set automatically for multipart
      if (headers != null) {
        final filteredHeaders = Map<String, String>.from(headers);
        filteredHeaders.remove('Content-Type');
        request.headers.addAll(filteredHeaders);
      }

      // Get file bytes and determine content type
      final fileBytes = await file.readAsBytes();
      final contentType = _getContentType(fileName);
      print('📁 File content type: $contentType');

      // Add file with proper content type
      final fileStream = http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: fileName,
        contentType: contentType,
      );
      request.files.add(fileStream);
      print('📤 File added to request: $fieldName = $fileName (using field name: $fieldName)');

      print('🚀 Sending multipart request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response received - Status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Upload failed with error: $e');
      throw _handleError(e);
    }
  }

  MediaType _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  void close() {
    client.close();
  }
}