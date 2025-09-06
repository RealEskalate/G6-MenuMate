import 'package:dio/dio.dart';

import '../../../../../../core/constants/constants.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../model/restaurant_model.dart';
import 'restaurant_remote_data_source_restaurant.dart';

const String content = 'application/json';

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final Dio dio;

  RestaurantRemoteDataSourceImpl({required this.dio});

  @override
  Future<RestaurantModel> createRestaurant(FormData restaurant) async {
    try {
      final response = await dio.post(
        '$baseUrl/restaurants',
        data: restaurant,
        options: Options(
          headers: {
            'Content-Type': content,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final statusCode = response.statusCode;
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
  Future<List<RestaurantModel>> getRestaurants(
      {int page = 1, int pageSize = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/restaurants').replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );
      final response = await dio.getUri(uri);
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final data = response.data['restaurants'] as List<dynamic>;
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
    try {
      final response = await dio.get(
        '$baseUrl/restaurants/$slug',
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
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
      FormData restaurant, String slug) async {
    try {
      final response = await dio.put(
        '$baseUrl/restaurants/$slug',
        data: restaurant,
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
}
