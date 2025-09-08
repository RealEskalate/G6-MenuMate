import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/review_repository.dart';

class GetUserImages {
  final ReviewRepository repository;

  GetUserImages(this.repository);
  Future<Either<Failure, List<String>>> call(String slug) async {
    return await repository.getUserImages(slug);
  }
}
