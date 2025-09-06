import 'package:file_picker/file_picker.dart';

import '../../data/models/resturant_model.dart';

abstract class ResturantRegRepo {
Future<ResturantModel> registerRestaurant({
    required String resturantname,
    required String returantphone,
    required PlatformFile verification_docs,
    PlatformFile? logo_image,
    PlatformFile? cover_image,
  });
}