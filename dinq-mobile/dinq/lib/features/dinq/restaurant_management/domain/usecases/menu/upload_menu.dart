import 'dart:io';
import 'package:fpdart/fpdart.dart';

import '../../../../../../core/error/failures.dart';
import '../../entities/menu.dart';
import '../../repositories/restaurant_repository.dart';

class UploadMenu {
  final RestaurantRepository repository;

  UploadMenu(this.repository);

  Future<Either<Failure, Menu>> call(File menuFile) async {
    return await repository.uploadMenu(menuFile);
  }
}
