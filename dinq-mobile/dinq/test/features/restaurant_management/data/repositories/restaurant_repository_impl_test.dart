import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/exceptions.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/restaurant_management/data/repositories/restaurant_repository_impl.dart';
import 'package:dinq/features/restaurant_management/domain/entities/category.dart';
import 'package:dinq/features/restaurant_management/domain/entities/menu.dart';
import 'package:dinq/features/restaurant_management/domain/entities/restaurant.dart';
import 'package:dinq/features/restaurant_management/domain/entities/review.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helper/entities/entity_fixtures.dart';
import '../../../../helper/mock/test.mocks.dart';

void main() {
  late RestaurantRepositoryImpl repository;
  late MockRestaurantRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRestaurantRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = RestaurantRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      network: mockNetworkInfo,
    );
  });

  group('RestaurantRepositoryImpl', () {
    group('getRestaurants', () {
      test(
        'should return restaurants when network is connected and call succeeds',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

          when(
            mockRemoteDataSource.getRestaurants(),
          ).thenAnswer((_) async => RestaurantFixtures.tRestaurantList);

          // Act
          final result = await repository.getRestaurants();

          // Assert
          result.fold(
            (failure) => fail('Should not return failure'),
            (restaurants) =>
                expect(restaurants, RestaurantFixtures.tRestaurantList),
          );
          verify(mockNetworkInfo.isConnected);
          verify(mockRemoteDataSource.getRestaurants());
        },
      );
      test(
        'should return ServerFailure when remote call throws exception',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

          when(
            mockRemoteDataSource.getRestaurants(),
          ).thenThrow(ServerException('Server error'));

          // Act
          final result = await repository.getRestaurants();

          // Assert
          expect(result, isA<Left<Failure, List<Restaurant>>>());
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (restaurants) => fail('Should return failure'),
          );
        },
      );
    });

    test(
      'should return NetworkFailure when network is not connected',
      () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.getRestaurants();

        // Assert
        expect(result, isA<Left<Failure, List<Restaurant>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (restaurants) => fail('Should return failure'),
        );
      },
    );

    group('getMenu', () {
      test(
        'should return menu when network is connected and call succeeds',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockRemoteDataSource.getMenu(MenuFixtures.tRestaurantId),
          ).thenAnswer((_) async => MenuFixtures.tMenu);

          // Act
          final result = await repository.getMenu(MenuFixtures.tRestaurantId);

          // Assert
          expect(result, Right(MenuFixtures.tMenu));
          verify(mockNetworkInfo.isConnected);
          verify(mockRemoteDataSource.getMenu(MenuFixtures.tRestaurantId));
        },
      );

      test(
        'should return ServerFailure when network is connected but server fails',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockRemoteDataSource.getMenu(MenuFixtures.tRestaurantId),
          ).thenThrow(ServerException('Server error'));

          // Act
          final result = await repository.getMenu(MenuFixtures.tRestaurantId);

          // Assert
          expect(result, isA<Left<Failure, Menu>>());
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (menu) => fail('Should return failure'),
          );
        },
      );

      test(
        'should return NetworkFailure when network is not connected',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

          // Act
          final result = await repository.getMenu(MenuFixtures.tRestaurantId);

          // Assert
          expect(result, isA<Left<Failure, Menu>>());
          result.fold(
            (failure) => expect(failure, isA<NetworkFailure>()),
            (menu) => fail('Should return failure'),
          );
        },
      );
    });

    group('getCategories', () {
      test(
        'should return categories when network is connected and call succeeds',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockRemoteDataSource.getCategories(CategoryFixtures.tTabId),
          ).thenAnswer((_) async => CategoryFixtures.tCategoryList);

          // Act
          final result = await repository.getCategories(
            CategoryFixtures.tTabId,
          );

          // Assert
          expect(result, Right(CategoryFixtures.tCategoryList));
          verify(mockNetworkInfo.isConnected);
          verify(mockRemoteDataSource.getCategories(CategoryFixtures.tTabId));
        },
      );

      test(
        'should return ServerFailure when network is connected but server fails',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockRemoteDataSource.getCategories(CategoryFixtures.tTabId),
          ).thenThrow(ServerException('Server error'));

          // Act
          final result = await repository.getCategories(
            CategoryFixtures.tTabId,
          );

          // Assert
          expect(result, isA<Left<Failure, List<Category>>>());
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (categories) => fail('Should return failure'),
          );
        },
      );

      test(
        'should return NetworkFailure when network is not connected',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

          // Act
          final result = await repository.getCategories(
            CategoryFixtures.tTabId,
          );

          // Assert
          expect(result, isA<Left<Failure, List<Category>>>());
          result.fold(
            (failure) => expect(failure, isA<NetworkFailure>()),
            (categories) => fail('Should return failure'),
          );
        },
      );
    });

    group('getReviews', () {
      test(
        'should return reviews when network is connected and call succeeds',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockRemoteDataSource.getReviews(ReviewFixtures.tItemId),
          ).thenAnswer((_) async => ReviewFixtures.tReviews);

          // Act
          final result = await repository.getReviews(ReviewFixtures.tItemId);

          // Assert
          expect(result, Right(ReviewFixtures.tReviews));
          verify(mockNetworkInfo.isConnected);
          verify(mockRemoteDataSource.getReviews(ReviewFixtures.tItemId));
        },
      );

      test(
        'should return ServerFailure when network is connected but server fails',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockRemoteDataSource.getReviews(ReviewFixtures.tItemId),
          ).thenThrow(ServerException('Server error'));

          // Act
          final result = await repository.getReviews(ReviewFixtures.tItemId);

          // Assert
          expect(result, isA<Left<Failure, List<Review>>>());
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (reviews) => fail('Should return failure'),
          );
        },
      );

      test(
        'should return NetworkFailure when network is not connected',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

          // Act
          final result = await repository.getReviews(ReviewFixtures.tItemId);

          // Assert
          expect(result, isA<Left<Failure, List<Review>>>());
          result.fold(
            (failure) => expect(failure, isA<NetworkFailure>()),
            (reviews) => fail('Should return failure'),
          );
        },
      );
    });

    group('getUserImages', () {
      const tSlug = 'doro-wat';
      final tUserImages = ['user1.jpg', 'user2.jpg'];

      test(
        'should return user images when network is connected and call succeeds',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockRemoteDataSource.getUserImages(tSlug),
          ).thenAnswer((_) async => tUserImages);

          // Act
          final result = await repository.getUserImages(tSlug);

          // Assert
          expect(result, Right(tUserImages));
          verify(mockNetworkInfo.isConnected);
          verify(mockRemoteDataSource.getUserImages(tSlug));
        },
      );

      test(
        'should return ServerFailure when network is connected but server fails',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockRemoteDataSource.getUserImages(tSlug),
          ).thenThrow(ServerException('Server error'));

          // Act
          final result = await repository.getUserImages(tSlug);

          // Assert
          expect(result, isA<Left<Failure, List<String>>>());
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (images) => fail('Should return failure'),
          );
        },
      );

      test(
        'should return NetworkFailure when network is not connected',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

          // Act
          final result = await repository.getUserImages(tSlug);

          // Assert
          expect(result, isA<Left<Failure, List<String>>>());
          result.fold(
            (failure) => expect(failure, isA<NetworkFailure>()),
            (images) => fail('Should return failure'),
          );
        },
      );
    });
  });
}
