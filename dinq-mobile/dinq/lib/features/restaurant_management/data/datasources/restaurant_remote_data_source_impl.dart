import 'package:dio/dio.dart';

import '../../../../core/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';
import '../model/category_model.dart';
import '../model/menu_model.dart';
import '../model/restaurant_model.dart';
import '../model/review_model.dart';
import 'restaurant_remote_data_source.dart';

const String _baseUrl = baseUrl;
const String _contentType = 'application/json';

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final Dio dio;
  final NetworkInfo network;

  RestaurantRemoteDataSourceImpl({required this.dio, required this.network});

  @override
  Future<List<Restaurant>> getRestaurants() async {
    if (await network.isConnected) {
      try {
        final response = await dio.get(
          '$_baseUrl/restaurants',
          options: Options(headers: {'Content-Type': _contentType}),
        );
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final data = response.data;
          return data
              .map((json) => RestaurantModel.fromMap(json).toEntity())
              .toList();
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
    } else {
      throw NetworkException(
        'No internet connection available. Please check your network settings and try again.',
      );
    }
  }

  @override
  Future<Menu> getMenu(String restaurantId) async {
    if (await network.isConnected) {
      try {
        final response = await dio.get(
          '$_baseUrl/restaurants/$restaurantId/menu',
          options: Options(headers: {'Content-Type': _contentType}),
        );
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          return MenuModel.fromMap(response.data).toEntity();
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
    } else {
      throw NetworkException(
        'No internet connection available. Please check your network settings and try again.',
      );
    }
  }

  @override
  Future<List<Category>> getCategories(String tabId) async {
    if (await network.isConnected) {
      try {
        final response = await dio.get(
          '$_baseUrl/tabs/$tabId/categories',
          options: Options(headers: {'Content-Type': _contentType}),
        );
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final List<dynamic> data = response.data;
          return data
              .map((json) => CategoryModel.fromMap(json).toEntity())
              .toList();
        } else {
          throw ServerException(
            HttpErrorHandler.getExceptionMessage(
              statusCode,
              'fetching categories for tab $tabId',
            ),
            statusCode: statusCode,
          );
        }
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'fetching categories for tab $tabId',
          ),
          statusCode: statusCode,
        );
      } catch (e) {
        throw ServerException(
          'Unexpected error occurred while fetching categories for tab $tabId: ${e.toString()}',
        );
      }
    } else {
      throw NetworkException(
        'No internet connection available. Please check your network settings and try again.',
      );
    }
  }

  @override
  Future<List<Review>> getReviews(String itemId) async {
    if (await network.isConnected) {
      try {
        final response = await dio.get(
          '$_baseUrl/items/$itemId/reviews',
          options: Options(headers: {'Content-Type': _contentType}),
        );
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final List<dynamic> data = response.data;
          return data
              .map((json) => ReviewModel.fromMap(json).toEntity())
              .toList();
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
    } else {
      throw NetworkException(
        'No internet connection available. Please check your network settings and try again.',
      );
    }
  }

  @override
  Future<List<String>> getUserImages(String slug) async {
    if (await network.isConnected) {
      try {
        final response = await dio.get(
          '$_baseUrl/items/$slug/images',
          options: Options(headers: {'Content-Type': _contentType}),
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
    } else {
      throw NetworkException(
        'No internet connection available. Please check your network settings and try again.',
      );
    }
  }
}
