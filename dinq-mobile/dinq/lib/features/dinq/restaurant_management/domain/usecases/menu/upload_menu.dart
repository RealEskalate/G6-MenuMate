import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../../data/model/menu_create_model.dart';
import '../../repositories/menu_repository.dart';

class UploadMenu {
  final MenuRepository repository;

  UploadMenu(this.repository);

  Future<Either<Failure, MenuCreateModel>> call(File menuFile) async {
    return await repository.uploadMenu(menuFile);
  }
}
