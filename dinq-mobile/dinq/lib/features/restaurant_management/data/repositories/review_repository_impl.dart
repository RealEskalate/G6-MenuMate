import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final NetworkInfo network;
  final ReviewRemoteDataSource reviewRemoteDataSource;

  ReviewRepositoryImpl({required this.network, required this.reviewRemoteDataSource});
  @override
  Future<Either<Failure, List<Review>>> getReviews(String itemId) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final reviewModels = await reviewRemoteDataSource.getReviews(itemId);
        return Right(reviewModels.map((m) => m.toEntity()).toList());
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        await reviewRemoteDataSource.deleteReview(reviewId);
        return const Right(null);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  // User Image
  @override
  Future<Either<Failure, List<String>>> getUserImages(String slug) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final itemDetails = await reviewRemoteDataSource.getUserImages(slug);
        return Right(itemDetails);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

}
