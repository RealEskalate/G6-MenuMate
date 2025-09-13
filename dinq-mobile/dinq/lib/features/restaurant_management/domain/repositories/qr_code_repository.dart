import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';

abstract class QrCodeRepository {
  Future<Either<Failure, Map<String, dynamic>>> generateQrCode({
    required String restaurantSlug,
    required String menuId,
    required Map<String, dynamic> customizationData,
  });
}
