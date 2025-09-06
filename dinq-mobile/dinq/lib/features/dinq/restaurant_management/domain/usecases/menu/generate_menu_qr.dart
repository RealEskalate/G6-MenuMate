import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/qr.dart';
import '../../repositories/menu_repository.dart';

class GenerateMenuQr {
  final MenuRepository repository;

  GenerateMenuQr(this.repository);

  Future<Either<Failure, Qr>> call({
    required String restaurantSlug,
    required String menuId,
    int? size,
    int? quality,
    bool? includeLabel,
    String? backgroundColor,
    String? foregroundColor,
    String? gradientFrom,
    String? gradientTo,
    String? gradientDirection,
    String? logo,
    double? logoSizePercent,
    int? margin,
    String? labelText,
    String? labelColor,
    int? labelFontSize,
    String? labelFontUrl,
  }) async {
    return await repository.generateMenuQr(
      restaurantSlug: restaurantSlug,
      menuId: menuId,
      size: size,
      quality: quality,
      includeLabel: includeLabel,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      gradientFrom: gradientFrom,
      gradientTo: gradientTo,
      gradientDirection: gradientDirection,
      logo: logo,
      logoSizePercent: logoSizePercent,
      margin: margin,
      labelText: labelText,
      labelColor: labelColor,
      labelFontSize: labelFontSize,
      labelFontUrl: labelFontUrl,
    );
  }
}
