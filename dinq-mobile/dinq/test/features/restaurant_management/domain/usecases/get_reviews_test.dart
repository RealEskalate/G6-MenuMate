import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/usecases/get_reviews.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helper/entities/entity_fixtures.dart';
import '../../../../helper/mock/test.mocks.dart';

void main() {
  late GetReviews usecase;
  late MockRestaurantRepository mockRepository;

  setUp(() => {
    mockRepository = MockRestaurantRepository(),
    usecase = GetReviews(mockRepository)
  });

  group('getReviews', () {
      test(
        'should return Right with list of reviews when successful',
        () async {
          // Arrange
          when(
            mockRepository.getReviews(ReviewFixtures.tItemId),
          ).thenAnswer((_) async => Right(ReviewFixtures.tReviews));

          // Act
          final result = await usecase(ReviewFixtures.tItemId);

          // Assert
          expect(result, Right(ReviewFixtures.tReviews));
          verify(mockRepository.getReviews(ReviewFixtures.tItemId));
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test('should return Left with failure when unsuccessful', () async {
        // Arrange
        const failure = ServerFailure('Reviews not found');
        when(
          mockRepository.getReviews(ReviewFixtures.tItemId),
        ).thenAnswer((_) async => const Left(failure));

        final result = await usecase(ReviewFixtures.tItemId);

        expect(result, const Left(failure));
        verify(mockRepository.getReviews(ReviewFixtures.tItemId));
        verifyNoMoreInteractions(mockRepository);
      });
    });

}
