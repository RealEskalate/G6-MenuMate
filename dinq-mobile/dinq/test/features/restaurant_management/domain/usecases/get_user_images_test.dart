import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/usecases/get_user_images.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helper/mock/test.mocks.dart';

void main() {
  late GetUserimages usecase;
  late MockRestaurantRepository mockRepository;
  setUp(
    () => {
      mockRepository = MockRestaurantRepository(),
      usecase = GetUserimages(mockRepository),
    },
  );

  group('getUserImages', () {
    test(
      'should return list of user images when the call to repository is successful',
      () async {
        // Arrange
        const slug = 'doro-wat';
        final userImages = ['user_image1.jpg', 'user_image2.jpg'];
        when(
          mockRepository.getUserImages(slug),
        ).thenAnswer((_) async => Right(userImages));

        // Act
        final result = await usecase(slug);

        // Assert
        expect(result, Right(userImages));
        verify(mockRepository.getUserImages(slug));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ServerFailure when the call to repository is unsuccessful',
      () async {
        // Arrange
        const slug = 'doro-wat';
        when(
          mockRepository.getUserImages(slug),
        ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

        // Act
        final result = await usecase(slug);

        // Assert
        expect(result, const Left(ServerFailure('Server error')));
        verify(mockRepository.getUserImages(slug));
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
