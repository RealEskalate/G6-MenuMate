import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/menu.dart';
import '../../repositories/menu_repository.dart';

class UploadMenu {
  final MenuRepository repository;

  UploadMenu(this.repository);

  Future<Either<Failure, Menu>> call(File menuFile) async {
    return await repository.uploadMenu(menuFile);
  }
}
