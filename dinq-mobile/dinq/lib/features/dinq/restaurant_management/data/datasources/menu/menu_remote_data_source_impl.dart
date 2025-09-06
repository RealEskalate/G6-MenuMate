import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../../core/constants/constants.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../model/menu_create_model.dart';
import '../../model/menu_model.dart';
import '../../model/qr_model.dart';
import 'menu_remote_data_source.dart';

const String content = 'application/json';

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;

  MenuRemoteDataSourceImpl({required this.dio});

  @override
  Future<MenuModel> uploadMenu(File printedMenu) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          printedMenu.path,
          filename: 'menu_image.jpg',
        ),
      });

      final uploadResponse = await dio.post(
        '$baseUrl/ocr/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final uploadStatusCode = uploadResponse.statusCode;

      if (uploadStatusCode == 200 || uploadStatusCode == 201) {
        final uploadData = uploadResponse.data;
        if (uploadData['success'] == true) {
          final jobId = uploadData['data']['jobId'] as String;

          while (true) {
            await Future.delayed(const Duration(seconds: 2));

            final pollResponse = await dio.get(
              '$baseUrl/ocr/$jobId',
              options: Options(
                headers: {
                  'Authorization': 'Bearer $accessToken',
                  'Content-Type': content,
                },
              ),
            );

            final pollStatusCode = pollResponse.statusCode;

            if (pollStatusCode == 200) {
              final pollData = pollResponse.data;
              if (pollData['success'] == true) {
                final status = pollData['data']['status'] as String;
                if (status == 'completed') {
                  final results = pollData['data']['results'];
                  return MenuModel.fromMap(results);
                } else if (status == 'failed') {
                  throw ServerException('OCR job failed', statusCode: 200);
                }
              } else {
                throw ServerException(
                  'Polling failed: ${pollData['message'] ?? 'Unknown error'}',
                  statusCode: pollStatusCode,
                );
              }
            } else {
              throw ServerException(
                HttpErrorHandler.getExceptionMessage(
                  pollStatusCode,
                  'polling OCR job',
                ),
                statusCode: pollStatusCode,
              );
            }
          }
        } else {
          throw ServerException(
            'Upload failed: ${uploadData['message'] ?? 'Unknown error'}',
            statusCode: uploadStatusCode,
          );
        }
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            uploadStatusCode,
            'uploading menu',
          ),
          statusCode: uploadStatusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'uploading menu'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while uploading menu: ${e.toString()}',
      );
    }
  }

  @override
  Future<MenuModel> getMenu(String restaurantSlug) async {
    try {
      print(
          'Sending request to get menu for restaurant:$baseUrl/menus/$restaurantSlug');

      final response = await dio.get(
        '$baseUrl/menus/$restaurantSlug',
        options: Options(headers: {
          'Content-Type': content,
          'Authorization': 'Bearer $accessToken'
        }),
      );

      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic>? menuMap;

        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic>) {
            final menuList = dataSection['menu'];
            if (menuList is List && menuList.isNotEmpty) {
              final first = menuList.first;
              if (first is Map<String, dynamic>) {
                menuMap = first;
              }
            }
          }

          if (menuMap == null) {
            if (responseData['menu'] is Map<String, dynamic>) {
              menuMap = responseData['menu'] as Map<String, dynamic>;
            } else if (responseData['data'] is Map<String, dynamic> &&
                responseData['data']['menu'] is Map<String, dynamic>) {
              menuMap = responseData['data']['menu'] as Map<String, dynamic>;
            }
          }
        }

        if (menuMap != null) {
          return MenuModel.fromMap(menuMap);
        }

        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'fetching menu for restaurant $restaurantSlug',
          ),
          statusCode: statusCode,
        );
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'fetching menu for restaurant $restaurantSlug',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'fetching menu for restaurant $restaurantSlug',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while fetching menu for restaurant $restaurantSlug: ${e.toString()}',
      );
    }
  }

  @override
  Future<MenuModel> publishMenu(
      {required String restaurantSlug, required String menuId}) async {
    try {
      final response = await dio.post(
        '$baseUrl/menus/$restaurantSlug/publish/$menuId',
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic>? menuMap;

        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic>) {
            final menuList = dataSection['menu'];
            if (menuList is List && menuList.isNotEmpty) {
              final first = menuList.first;
              if (first is Map<String, dynamic>) {
                menuMap = first;
              }
            }
          }

          if (menuMap == null) {
            if (responseData['menu'] is Map<String, dynamic>) {
              menuMap = responseData['menu'] as Map<String, dynamic>;
            } else if (responseData['data'] is Map<String, dynamic> &&
                responseData['data']['menu'] is Map<String, dynamic>) {
              menuMap = responseData['data']['menu'] as Map<String, dynamic>;
            }
          }
        }

        if (menuMap != null) {
          return MenuModel.fromMap(menuMap);
        }

        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'publishing menu for restaurant $restaurantSlug',
          ),
          statusCode: statusCode,
        );
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'publishing menu for restaurant $restaurantSlug',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'publishing menu for restaurant $restaurantSlug',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while publishing menu for restaurant $restaurantSlug: ${e.toString()}',
      );
    }
  }

  @override
  Future<MenuModel> createMenu(MenuCreateModel menu) async {
    try {
      final response = await dio.post(
        '$baseUrl/menus',
        data: menu.toMap(),
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        final responseData = response.data;
        Map<String, dynamic>? menuMap;

        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic>) {
            final menuList = dataSection['menu'];
            if (menuList is List && menuList.isNotEmpty) {
              final first = menuList.first;
              if (first is Map<String, dynamic>) {
                menuMap = first;
              }
            }
          }

          if (menuMap == null) {
            if (responseData['menu'] is Map<String, dynamic>) {
              menuMap = responseData['menu'] as Map<String, dynamic>;
            } else if (responseData['data'] is Map<String, dynamic> &&
                responseData['data']['menu'] is Map<String, dynamic>) {
              menuMap = responseData['data']['menu'] as Map<String, dynamic>;
            }
          }
        }

        if (menuMap != null) {
          return MenuModel.fromMap(menuMap);
        }

        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'creating menu',
          ),
          statusCode: statusCode,
        );
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'creating menu',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'creating menu'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while creating menu: ${e.toString()}',
      );
    }
  }

  @override
  Future<QrModel> generateQr({
    required String restaurantSlug,
    required String menuId,
    required Map<String, Object?> custom,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/menus/$restaurantSlug/qrcode/$menuId',
        data: custom,
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic> &&
              dataSection['qr_code'] is Map<String, dynamic>) {
            return QrModel.fromMap(
                Map<String, dynamic>.from(dataSection['qr_code']));
          }
        }

        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
              statusCode, 'generating qr code'),
          statusCode: statusCode,
        );
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
              statusCode, 'generating qr code'),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'generating qr code'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
          'Unexpected error occurred while generating QR: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMenu(String menuId) async {
    try {
      final response = await dio.delete(
        '$baseUrl/menus/$menuId',
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 204) {
        return;
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(statusCode, 'deleting menu'),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'deleting menu'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
          'Unexpected error occurred while deleting menu: ${e.toString()}');
    }
  }

  @override
  Future<MenuModel> updateMenu(
      {required String restaurantSlug,
      required String menuId,
      String? title,
      String? description}) async {
    try {
      final body = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      };

      final response = await dio.patch(
        '$baseUrl/menus/$restaurantSlug/$menuId',
        data: body,
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        final responseData = response.data;
        Map<String, dynamic>? menuMap;

        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic>) {
            final menuObj = dataSection['menu'];
            if (menuObj is Map<String, dynamic>) {
              menuMap = menuObj;
            }
          }

          if (menuMap == null) {
            if (responseData['menu'] is Map<String, dynamic>) {
              menuMap = responseData['menu'] as Map<String, dynamic>;
            }
          }
        }

        if (menuMap != null) {
          return MenuModel.fromMap(menuMap);
        }

        throw ServerException(
          HttpErrorHandler.getExceptionMessage(statusCode, 'updating menu'),
          statusCode: statusCode,
        );
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(statusCode, 'updating menu'),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'updating menu'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
          'Unexpected error occurred while updating menu: ${e.toString()}');
    }
  }
}
