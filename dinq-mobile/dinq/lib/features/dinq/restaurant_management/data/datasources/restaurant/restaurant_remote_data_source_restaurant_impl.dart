import 'package:dio/dio.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/network/token_manager.dart';
import '../../model/restaurant_model.dart';
import 'restaurant_remote_data_source_restaurant.dart';

const String content = 'application/json';

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final Dio dio;

  RestaurantRemoteDataSourceImpl({required this.dio});

  @override
  Future<RestaurantModel> createRestaurant(FormData restaurant) async {
    try {
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.post(
        ApiEndpoints.restaurants,
        data: restaurant,
        options: Options(headers: headers),
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
      final uri = Uri.parse(ApiEndpoints.restaurants).replace(
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
  Future<List<RestaurantModel>> searchRestaurants({
    required String name,
    int page = 1,
    int pageSize = 10,
  }) async {
    // Implemented based on previous combined datasource logic
    try {
      final uri = Uri.parse('${ApiEndpoints.restaurants}/search').replace(
        queryParameters: {
          'q': name,
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response =
          await dio.getUri(uri, options: Options(headers: headers));

      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final data = response.data;
        // normalize response: expect either { 'restaurants': [...] } or list itself
        List<dynamic> list = [];
        if (data is Map && data.containsKey('restaurants')) {
          list = data['restaurants'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        } else if (data is Map &&
            data['data'] is Map &&
            data['data']['restaurants'] is List) {
          list = data['data']['restaurants'] as List<dynamic>;
        }

        return list.map((json) => RestaurantModel.fromMap(json)).toList();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'searching restaurants',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'searching restaurants',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while searching restaurants: ${e.toString()}',
      );
    }
  }

  @override
  Future<RestaurantModel> getRestaurantBySlug(String slug) async {
    try {
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.get(
        ApiEndpoints.restaurantBySlug(slug),
        options: Options(headers: headers),
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
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.put(
        ApiEndpoints.restaurantBySlug(slug),
        data: restaurant,
        options: Options(headers: headers),
      );
      final statuscode = response.statusCode;
      // debug: log datasource call and status
      // ignore: avoid_print
      print(
          'RestaurantRemoteDataSourceImpl.updateRestaurant called - status: $statuscode');
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
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.delete(
        ApiEndpoints.restaurantById(restaurantId),
        options: Options(headers: headers),
      );
      final statusCode = response.statusCode;
      // debug: log datasource call and status
      // ignore: avoid_print
      print(
          'RestaurantRemoteDataSourceImpl.deleteRestaurant called - status: $statusCode');
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
