import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/repositories/qr_code_repository.dart';
import '../datasources/qr_code_remote_data_source.dart';

class QrCodeRepositoryImpl implements QrCodeRepository {
  final QrCodeRemoteDataSource remoteDataSource;

  QrCodeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateQrCode({
    required String restaurantSlug,
    required String menuId,
    required Map<String, dynamic> customizationData,
  }) async {
    try {
      final result = await remoteDataSource.generateQrCode(
        restaurantSlug: restaurantSlug,
        menuId: menuId,
        customizationData: customizationData,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
