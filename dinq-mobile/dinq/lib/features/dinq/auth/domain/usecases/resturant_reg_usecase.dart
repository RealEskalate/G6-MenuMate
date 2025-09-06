import '../../data/models/resturant_model.dart';
// import '../repository/Customer_reg_repo.dart';

import 'package:file_picker/file_picker.dart';

import '../repository/Customer_reg_repo.dart';
import '../repository/resturant_reg_repo.dart';

class ResturantRegUsecase {
  final ResturantRegRepo repo;

  ResturantRegUsecase({required this.repo});
  Future<ResturantModel> call({
    required String resturantname,
    required String returantphone,
    required PlatformFile verification_docs,
    PlatformFile? logo_image,
    PlatformFile? cover_image,
  }) async {
    final resturant = await repo.registerRestaurant(
      resturantname: resturantname,
      returantphone: returantphone,
      verification_docs: verification_docs,
      logo_image: logo_image,
      cover_image: cover_image,
    );
    return resturant;
  }
}
