import 'package:dio/dio.dart';

import '../../../../core/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/temp/app_config.dart';
import '../../../../core/temp/demo_http_client.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';
import '../model/category_model.dart';
import '../model/item_model.dart';
import '../model/menu_model.dart';
import '../model/restaurant_model.dart';
import '../model/review_model.dart';
import 'restaurant_remote_data_source.dart';

const String content = 'application/json';

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
    print(
      '🔄 Restaurant DataSource Demo Mode: ${_demoClient.isDemoMode ? 'ENABLED' : 'DISABLED'}',
    );
  }

  /// Check if demo mode is enabled
  bool get isDemoMode => _demoClient.isDemoMode;

  @override
  Future<Restaurant> createRestaurant(RestaurantModel restaurant) async {
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
      if (statusCode == 201 || statusCode == 200) {
        return RestaurantModel.fromMap(response.data).toEntity();
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
  Future<List<Restaurant>> getRestaurants(int page, int pageSize) async {
    try {
      final response = await dio.get(
        '$baseUrl/restaurants',
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: Options(headers: {'Content-Type': content}),
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
  Future<Restaurant> getRestaurantBySlug(String slug) async {
    try {
      final response = await dio.get(
        '$baseUrl/restaurants/$slug',
        options: Options(headers: {'Content-Type': content}),
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return RestaurantModel.fromMap(response.data).toEntity();
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
  Future<Restaurant> updateRestaurant(
    RestaurantModel restaurant,
    String slug,
  ) async {
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
        return RestaurantModel.fromMap(response.data).toEntity();
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

  @override
  Future<Menu> getMenu(String restaurantId) async {
    try {
      final response = await dio.get(
        '$baseUrl/menus/:$restaurantId',
        options: Options(headers: {'Content-Type': content}),
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
        '$baseUrl/tabs/$tabId/categories',
        options: Options(headers: {'Content-Type': content}),
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
        '$baseUrl/items/$itemId/reviews',
        options: Options(headers: {'Content-Type': content}),
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
  
  @override
  Future<Restaurant> addRestaurant(Restaurant restaurant) async {
    try {
      final restaurantModel = restaurant as RestaurantModel;
      final response = await dio.post(
        '$_baseUrl/restaurants',
        data: restaurantModel.toJson(),
        options: Options(headers: {'Content-Type': _contentType}),
      );
      
      final statusCode = response.statusCode;
      if (statusCode == 201 || statusCode == 200) {
        return RestaurantModel.fromMap(response.data).toEntity();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'adding restaurant',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'adding restaurant',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while adding restaurant: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<Item> addItem(String categoryId, Item item) async {
    try {
      final itemModel = item as ItemModel;
      final response = await dio.post(
        '$_baseUrl/categories/$categoryId/items',
        data: itemModel.toJson(),
        options: Options(headers: {'Content-Type': _contentType}),
      );
      
      final statusCode = response.statusCode;
      if (statusCode == 201 || statusCode == 200) {
        return ItemModel.fromMap(response.data).toEntity();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'adding item to category $categoryId',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'adding item to category $categoryId',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while adding item to category $categoryId: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<Restaurant> updateRestaurant(String restaurantId, Restaurant restaurant) async {
    try {
      final restaurantModel = restaurant as RestaurantModel;
      final response = await dio.put(
        '$_baseUrl/restaurants/$restaurantId',
        data: restaurantModel.toJson(),
        options: Options(headers: {'Content-Type': _contentType}),
      );
      
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return RestaurantModel.fromMap(response.data).toEntity();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'updating restaurant $restaurantId',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'updating restaurant $restaurantId',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while updating restaurant $restaurantId: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<Menu> updateMenu(String restaurantId, Menu menu) async {
    try {
      final menuModel = menu as MenuModel;
      final response = await dio.put(
        '$_baseUrl/restaurants/$restaurantId/menu',
        data: menuModel.toJson(),
        options: Options(headers: {'Content-Type': _contentType}),
      );
      
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return MenuModel.fromMap(response.data).toEntity();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'updating menu for restaurant $restaurantId',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'updating menu for restaurant $restaurantId',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while updating menu for restaurant $restaurantId: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<Item> updateItem(String itemId, Item item) async {
    try {
      final itemModel = item as ItemModel;
      final response = await dio.put(
        '$_baseUrl/items/$itemId',
        data: itemModel.toJson(),
        options: Options(headers: {'Content-Type': _contentType}),
      );
      
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        return ItemModel.fromMap(response.data).toEntity();
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'updating item $itemId',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'updating item $itemId',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while updating item $itemId: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<bool> deleteItem(String itemId) async {
    try {
      final response = await dio.delete(
        '$_baseUrl/items/$itemId',
        options: Options(headers: {'Content-Type': _contentType}),
      );
      
      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 204) {
        return true;
      } else {
        throw ServerException(
          HttpErrorHandler.getExceptionMessage(
            statusCode,
            'deleting item $itemId',
          ),
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        HttpErrorHandler.getExceptionMessage(
          statusCode,
          'deleting item $itemId',
        ),
        statusCode: statusCode,
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error occurred while deleting item $itemId: ${e.toString()}',
      );
    }
  }
}
