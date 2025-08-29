import 'package:dio/dio.dart';

import '../../../../core/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/temp/app_config.dart';
import '../../../../core/temp/demo_http_client.dart';
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
  late final DemoHttpClient _demoClient;

  RestaurantRemoteDataSourceImpl({required this.dio}) {
    _demoClient = DemoHttpClient(dio);
    _demoClient.setDemoMode(AppConfig.useDemoMode);
  }

  /// Toggle demo mode for this data source
  void toggleDemoMode() {
    _demoClient.setDemoMode(!_demoClient.isDemoMode);
    // ignore: avoid_print
    print('🔄 Restaurant DataSource Demo Mode: ${_demoClient.isDemoMode ? 'ENABLED' : 'DISABLED'}');
  }

  /// Check if demo mode is enabled
  bool get isDemoMode => _demoClient.isDemoMode;

  @override
  Future<List<Restaurant>> getRestaurants() async {
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
    
  }

  @override
  Future<Menu> getMenu(String restaurantId) async {
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
  }

  @override
  Future<List<Category>> getCategories(String tabId) async {
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
  }

  @override
  Future<List<Review>> getReviews(String itemId) async {
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
  }

  @override
  Future<List<String>> getUserImages(String slug) async {
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
  }
}
