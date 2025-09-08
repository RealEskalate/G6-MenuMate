import 'package:dio/dio.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/network/token_manager.dart';
import '../../model/review_model.dart';
import 'review_remote_data_source.dart';

const String content = 'application/json';

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;

  ReviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ReviewModel>> getReviews(String itemId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.itemReviews(itemId),
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
    try {
      final headers = await TokenManager.getAuthHeadersStatic();
      headers['Content-Type'] = content;
      final response = await dio.delete(
        ApiEndpoints.deleteReview(reviewId),
        options: Options(headers: headers),
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
    try {
      final response = await dio.get(
        ApiEndpoints.itemImages(slug),
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
