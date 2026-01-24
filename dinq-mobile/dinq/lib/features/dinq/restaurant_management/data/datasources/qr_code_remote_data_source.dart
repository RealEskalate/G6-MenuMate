import 'dart:convert';
import 'dart:io';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/constants.dart';

abstract class QrCodeRemoteDataSource {
  Future<Map<String, dynamic>> generateQrCode({
    required String restaurantSlug,
    required String menuId,
    required Map<String, dynamic> customizationData,
  });
}

class QrCodeRemoteDataSourceImpl implements QrCodeRemoteDataSource {
  final ApiClient apiClient;

  QrCodeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> generateQrCode({
    required String restaurantSlug,
    required String menuId,
    required Map<String, dynamic> customizationData,
  }) async {
    try {
      print('🔄 Generating QR code for restaurant: $restaurantSlug, menu: $menuId');
      print('🎨 Customization data: $customizationData');

      final endpoint = '/menus/$restaurantSlug/qrcode/$menuId';

      final response = await apiClient.post(
        endpoint,
        body: customizationData,
      );

      print('✅ QR code generation successful');
      return response;
    } catch (e) {
      print('❌ QR code generation failed: $e');
      rethrow;
    }
  }
}
