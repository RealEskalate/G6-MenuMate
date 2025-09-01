import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/restaurant_management/domain/usecases/get_categories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helper/entities/entity_fixtures.dart';
import '../../../../helper/mock/test.mocks.dart';

void main() {
  late GetCategories usecase;
  late MockRestaurantRepository mockRepository;

  setUp(
    () => {
      mockRepository = MockRestaurantRepository(),
      usecase = GetCategories(mockRepository),
    },
  );
  group('get categories', () {
    test(
      'Should return list of categories when get categories is successful',
      () async {
        when(
          mockRepository.getCategories(CategoryFixtures.tTabId),
        ).thenAnswer((_) async => Right(CategoryFixtures.tCategoryList));

        final result = await usecase(CategoryFixtures.tTabId);
        expect(result, Right(CategoryFixtures.tCategoryList));
      },
    );
    test('Should return failure when there is server failure', () async {
      when(
          mockRepository.getCategories(CategoryFixtures.tTabId),
        ).thenAnswer((_) async => const Left(ServerFailure('Server Failure')));

        final result = await usecase(CategoryFixtures.tTabId);
        expect(result, const Left(ServerFailure('Server Failure')));
    });
  });
}
