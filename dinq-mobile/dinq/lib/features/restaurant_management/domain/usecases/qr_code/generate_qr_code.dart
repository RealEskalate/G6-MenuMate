import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/qr_code_repository.dart';

class GenerateQrCode {
  final QrCodeRepository repository;

  GenerateQrCode(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String restaurantSlug,
    required String menuId,
    required Map<String, dynamic> customizationData,
  }) async {
    return await repository.generateQrCode(
      restaurantSlug: restaurantSlug,
      menuId: menuId,
      customizationData: customizationData,
    );
  }
}
