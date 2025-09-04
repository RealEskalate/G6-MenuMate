import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/usecases/menu/get_menu.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helper/entities/entity_fixtures.dart';
import '../../../../helper/mock/test.mocks.dart';

void main() {
  late GetMenu usecase;
  late MockRestaurantRepository mockRepository;

  setUp(() {
    mockRepository = MockRestaurantRepository();
    usecase = GetMenu(mockRepository);
  });

  group('GetMenu', () {
    test('should get menu from repository with valid restaurant id', () async {
      // Arrange
      when(
        mockRepository.getMenu(MenuFixtures.tRestaurantId),
      ).thenAnswer((_) async => Right(MenuFixtures.tMenu));

      // Act
      final result = await usecase(MenuFixtures.tRestaurantId);

      // Assert
      expect(result, Right(MenuFixtures.tMenu));
      verify(mockRepository.getMenu(MenuFixtures.tRestaurantId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return server failure when menu not found', () async {
      // Arrange
      const failure = ServerFailure('Menu not found');
      when(
        mockRepository.getMenu(MenuFixtures.tRestaurantId),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(MenuFixtures.tRestaurantId);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getMenu(MenuFixtures.tRestaurantId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
