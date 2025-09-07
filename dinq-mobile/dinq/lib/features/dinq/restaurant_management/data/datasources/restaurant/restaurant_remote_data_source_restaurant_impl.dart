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
      // debug: log datasource call and status
      // ignore: avoid_print
      print(
          'RestaurantRemoteDataSourceImpl.createRestaurant called - status: $statusCode');
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
      // debug: log datasource call and status
      // ignore: avoid_print
      print(
          'RestaurantRemoteDataSourceImpl.getRestaurants called - status: $statusCode');
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
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.get(
        ApiEndpoints.restaurantBySlug(slug),
        options: Options(headers: headers),
      );
      final statusCode = response.statusCode;
      // debug: log datasource call and status
      // ignore: avoid_print
      print(
          'RestaurantRemoteDataSourceImpl.getRestaurantBySlug called - status: $statusCode');
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
