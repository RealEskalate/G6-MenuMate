import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/network/token_manager.dart';
import '../../model/menu_create_model.dart';
import '../../model/menu_model.dart';
import '../../model/qr_model.dart';
import 'menu_remote_data_source.dart';

const String content = 'application/json';

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;

  MenuRemoteDataSourceImpl({required this.dio});

  @override
  Future<MenuCreateModel> uploadMenu(File printedMenu) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          printedMenu.path,
          filename: 'menu_image.jpg',
        ),
      });

      final headers = await (await TokenManager.getAuthHeadersStatic())
        ..addAll({'Content-Type': 'multipart/form-data'});

      final uploadResponse = await dio.post(
        ApiEndpoints.ocrUpload,
        data: formData,
        options: Options(headers: headers),
      );

      final uploadStatusCode = uploadResponse.statusCode;

      if (uploadStatusCode == 200 || uploadStatusCode == 201) {
        final uploadData = uploadResponse.data;
        if (uploadData['success'] == true) {
          final jobId = uploadData['data']['jobId'] as String;

          while (true) {
            await Future.delayed(const Duration(seconds: 2));

            final pollHeaders = await TokenManager.getAuthHeadersStatic();
            pollHeaders['Content-Type'] = content;
            final pollResponse = await dio.get(
              ApiEndpoints.ocrJob(jobId),
              options: Options(headers: pollHeaders),
            );

            final pollStatusCode = pollResponse.statusCode;

            if (pollStatusCode == 200) {
              final pollData = pollResponse.data;
              if (pollData['success'] == true) {
                final status = pollData['data']['status'] as String;
                if (status == 'completed') {
                  final results = pollData['data']['results'];

                  // Build a MenuCreateModel prefill from OCR results
                  final extractedText = results['extracted_text'] as String?;
                  final rawItems = results['menu_items'] ?? results['items'];
                  final List<Map<String, dynamic>> items = [];
                  if (rawItems is List) {
                    for (final rawItem in rawItems) {
                      if (rawItem is Map<String, dynamic>) {
                        items.add(rawItem);
                      }
                    }
                  }

                  final Map<String, dynamic> createPayload = {
                    'title': 'Scanned menu',
                    'description': extractedText ?? '',
                    'items': items,
                  };

                  return MenuCreateModel.fromMap(createPayload);
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
          'Sending request to get menu for restaurant:${ApiEndpoints.menusForRestaurant(restaurantSlug)}');

      final getHeaders = await TokenManager.getAuthHeadersStatic();
      getHeaders['Content-Type'] = content;
      final response = await dio.get(
        ApiEndpoints.menusForRestaurant(restaurantSlug),
        options: Options(headers: getHeaders),
      );
      print(response);
      final statusCode = response.statusCode;

      if (statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic>? menuMap;

        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic>) {
            final menuList = dataSection['menus'];
            if (menuList is List && menuList.isNotEmpty) {
              final first = menuList.first;
              if (first is Map<String, dynamic>) {
                menuMap = first;
              }
            }
          }

          if (menuMap == null) {
            if (responseData['menus'] is Map<String, dynamic>) {
              menuMap = responseData['menus'] as Map<String, dynamic>;
            } else if (responseData['data'] is Map<String, dynamic> &&
                responseData['data']['menus'] is Map<String, dynamic>) {
              menuMap = responseData['data']['menus'] as Map<String, dynamic>;
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
      final publishHeaders = await TokenManager.getAuthHeadersStatic();
      publishHeaders['Content-Type'] = content;
      final response = await dio.post(
        ApiEndpoints.publishMenu(restaurantSlug, menuId),
        options: Options(headers: publishHeaders),
      );

      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic>? menuMap;

        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic>) {
            final menuList = dataSection['menus'];
            if (menuList is List && menuList.isNotEmpty) {
              final first = menuList.first;
              if (first is Map<String, dynamic>) {
                menuMap = first;
              }
            }
          }

          if (menuMap == null) {
            if (responseData['menus'] is Map<String, dynamic>) {
              menuMap = responseData['menus'] as Map<String, dynamic>;
            } else if (responseData['data'] is Map<String, dynamic> &&
                responseData['data']['menus'] is Map<String, dynamic>) {
              menuMap = responseData['data']['menus'] as Map<String, dynamic>;
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
      final createHeaders = await TokenManager.getAuthHeadersStatic();
      createHeaders['Content-Type'] = content;
      final response = await dio.post(
        ApiEndpoints.menus,
        data: menu.toMap(),
        options: Options(headers: createHeaders),
      );

      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        final responseData = response.data;
        Map<String, dynamic>? menuMap;

        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic>) {
            final menuList = dataSection['menus'];
            if (menuList is List && menuList.isNotEmpty) {
              final first = menuList.first;
              if (first is Map<String, dynamic>) {
                menuMap = first;
              }
            }
          }

          if (menuMap == null) {
            if (responseData['menus'] is Map<String, dynamic>) {
              menuMap = responseData['menus'] as Map<String, dynamic>;
            } else if (responseData['data'] is Map<String, dynamic> &&
                responseData['data']['menus'] is Map<String, dynamic>) {
              menuMap = responseData['data']['menus'] as Map<String, dynamic>;
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
      final qrHeaders = await TokenManager.getAuthHeadersStatic();
      qrHeaders['Content-Type'] = content;
      final response = await dio.post(
        ApiEndpoints.menuQr(restaurantSlug, menuId),
        data: custom,
        options: Options(headers: qrHeaders),
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
      final delHeaders = await TokenManager.getAuthHeadersStatic();
      delHeaders['Content-Type'] = content;
      final response = await dio.delete(
        ApiEndpoints.menuById(menuId),
        options: Options(headers: delHeaders),
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

      final patchHeaders = await TokenManager.getAuthHeadersStatic();
      patchHeaders['Content-Type'] = content;
      final response = await dio.patch(
        ApiEndpoints.updateMenu(restaurantSlug, menuId),
        data: body,
        options: Options(headers: patchHeaders),
      );

      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        final responseData = response.data;
        Map<String, dynamic>? menuMap;

        if (responseData is Map<String, dynamic>) {
          final dataSection = responseData['data'];
          if (dataSection is Map<String, dynamic>) {
            final menuObj = dataSection['menus'];
            if (menuObj is Map<String, dynamic>) {
              menuMap = menuObj;
            }
          }

          if (menuMap == null) {
            if (responseData['menus'] is Map<String, dynamic>) {
              menuMap = responseData['menus'] as Map<String, dynamic>;
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
