import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../model/menu_model.dart';
import '../model/restaurant_model.dart';
import '../model/review_model.dart';
import 'restaurant_remote_data_source.dart';

const String content = 'application/json';

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final Dio dio;

  RestaurantRemoteDataSourceImpl({required this.dio});

  @override
  Future<RestaurantModel> createRestaurant(RestaurantModel restaurant) async {
    print('[Remote] createRestaurant - POST /restaurants');
    try {
      final response = await dio.post(
        '$baseUrl/restaurants',
        data: restaurant.toMap(),
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final statusCode = response.statusCode;
      print(
        '[Remote] createRestaurant - response status=$statusCode data=${response.data}',
      );
      if (statusCode == 201 || statusCode == 200) {
        return RestaurantModel.fromMap(response.data);
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'creating restaurant',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'creating restaurant'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while creating restaurant: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurants({
    int page = 1,
    int pageSize = 20,
  }) async {
    print(
      '[Remote] getRestaurants - GET /restaurants?page=$page&pageSize=$pageSize',
    );
    try {
      final uri = Uri.parse('$baseUrl/restaurants').replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );
      print('[Remote][Request] GET ${uri.toString()}');
      print('[Remote][Request] dio.defaultHeaders=${dio.options.headers}');
      print('[Remote][Request] requestOptions.headers=');
      final response = await dio.getUri(uri);
      final statusCode = response.statusCode;
      print(
        '[Remote] getRestaurants - response status=$statusCode data=${response.data}',
      );
      if (statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((json) => RestaurantModel.fromMap(json)).toList();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'fetching restaurants list',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'fetching restaurants list',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while fetching restaurants list: ${e.toString()}',
      );
    }
  }

  @override
  Future<RestaurantModel> getRestaurantBySlug(String slug) async {
    print('[Remote] getRestaurantBySlug - GET /restaurants/$slug');
    try {
      final response = await dio.get(
        '$baseUrl/restaurants/$slug',
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      print(
        '[Remote] getRestaurantBySlug - response status=$statusCode data=${response.data}',
      );
      if (statusCode == 200) {
        return RestaurantModel.fromMap(response.data);
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'fetching restaurants list',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'fetching restaurants list',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while fetching restaurants list: ${e.toString()}',
      );
    }
  }

  @override
  Future<RestaurantModel> updateRestaurant(
    RestaurantModel restaurant,
    String slug,
  ) async {
    print('[Remote] updateRestaurant - PUT /restaurants/$slug');
    try {
      final response = await dio.put(
        '$baseUrl/restaurants/$slug',
        data: restaurant.toMap(),
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final statuscode = response.statusCode;
      if (statuscode == 200) {
        return RestaurantModel.fromMap(response.data);
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statuscode,
            'PUT: update restaurant',
          ),
          statusCode: statuscode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'fetching restaurants list',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while fetching restaurants list: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteRestaurant(String restaurantId) async {
    print('[Remote] deleteRestaurant - DELETE /restaurants/$restaurantId');
    try {
      final response = await dio.delete(
        '$baseUrl/restaurants/$restaurantId',
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
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'deleting restaurant',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'deleting restaurant'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while deleting restaurant: ${e.toString()}',
      );
    }
  }

  @override
  Future<MenuModel> uploadMenu(File printedMenu) async {
    print('[Remote] uploadMenu - POST /ocr/upload');
    try {
      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          printedMenu.path,
          filename: 'menu_image.jpg',  // Adjust filename as needed
        ),
      });

      // POST to upload endpoint
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
      print('[Remote] uploadMenu - upload response status=$uploadStatusCode data=${uploadResponse.data}');

      if (uploadStatusCode == 200 || uploadStatusCode == 201) {
        final uploadData = uploadResponse.data;
        if (uploadData['success'] == true) {
          final jobId = uploadData['data']['jobId'] as String;
          print('[Remote] uploadMenu - jobId: $jobId');

          // Poll the job status every 2 seconds until completed
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
            print('[Remote] uploadMenu - poll response status=$pollStatusCode data=${pollResponse.data}');

            if (pollStatusCode == 200) {
              final pollData = pollResponse.data;
              if (pollData['success'] == true) {
                final status = pollData['data']['status'] as String;
                if (status == 'completed') {
                  // Parse the results into MenuModel
                  final results = pollData['data']['results'];
                  // Assuming MenuModel.fromMap can handle the results structure
                  // If MenuModel expects a specific format, adjust accordingly (e.g., wrap in a map)
                  return MenuModel.fromMap(results);
                } else if (status == 'failed') {
                  throw ServerException(
                    'OCR job failed',
                    statusCode: 200,
                  );
                }
                // Continue polling if still processing
              } else {
                throw ServerException(
                  'Polling failed: ${pollData['message'] ?? 'Unknown error'}',
                  statusCode: pollStatusCode,
                );
              }
            } else {
              throw ServerException(
                HttpErrorHandler.getExceptionMessage(pollStatusCode, 'polling OCR job'),
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
          HttpErrorHandler.getExceptionMessage(uploadStatusCode, 'uploading menu'),
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
  Future<MenuModel> getMenu(String restaurantId) async {
    print(
      '[Remote] getMenu - GET /menus/<restaurantId> (requested: $restaurantId)',
    );
    try {
      final response = await dio.get(
        '$baseUrl/menus/:$restaurantId',
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return MenuModel.fromMap(response.data);
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'fetching menu for restaurant $restaurantId',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'fetching menu for restaurant $restaurantId',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while fetching menu for restaurant $restaurantId: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteMenu(String menuId) async {
    print('[Remote] deleteMenu - DELETE /menus/$menuId');
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
        'Unexpected error occurred while deleting menu: ${e.toString()}',
      );
    }
  }

  @override
  Future<MenuModel> updateMenu(MenuModel menu) async {
    print('[Remote] updateMenu - PUT /menus/${menu.id}');
    try {
      final response = await dio.put(
        '$baseUrl/menus/${menu.id}',
        data: menu.toMap(),
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return MenuModel.fromMap(response.data);
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
        'Unexpected error occurred while updating menu: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ReviewModel>> getReviews(String itemId) async {
    print('[Remote] getReviews - GET /items/$itemId/reviews');
    try {
      final response = await dio.get(
        '$baseUrl/items/$itemId/reviews',
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReviewModel.fromMap(json)).toList();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'fetching reviews for item $itemId',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'fetching reviews for item $itemId',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while fetching reviews for item $itemId: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    print('[Remote] deleteReview - DELETE /reviews/$reviewId');
    try {
      final response = await dio.delete(
        '$baseUrl/reviews/$reviewId',
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
          HttpErrorHandler.getExceptionMessage(statusCode, 'deleting review'),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(statusCode, 'deleting review'),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while deleting review: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getUserImages(String slug) async {
    print('[Remote] getUserImages - GET /items/$slug/images');
    try {
      final response = await dio.get(
        '$baseUrl/items/$slug/images',
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => json.toString()).toList();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'fetching user images for item $slug',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'fetching user images for item $slug',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while fetching user images for item $slug: ${e.toString()}',
      );
    }
  }

}
