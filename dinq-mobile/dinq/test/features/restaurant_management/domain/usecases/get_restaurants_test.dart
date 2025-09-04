import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/usecases/get_restaurants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helper/entities/entity_fixtures.dart';
import '../../../../helper/mock/test.mocks.dart';

void main() {
  late GetRestaurants usecase;
  late MockRestaurantRepository mockRepository;

  setUp(() {
    mockRepository = MockRestaurantRepository();
    usecase = GetRestaurants(mockRepository);
  });

  group('GetRestaurants', () {
    test('should get restaurants from the repository', () async {
      // Arrange
      when(
        mockRepository.getRestaurants(),
      ).thenAnswer((_) async => Right(RestaurantFixtures.tRestaurantList));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(RestaurantFixtures.tRestaurantList));
      verify(mockRepository.getRestaurants());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return server failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(
        mockRepository.getRestaurants(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getRestaurants());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
