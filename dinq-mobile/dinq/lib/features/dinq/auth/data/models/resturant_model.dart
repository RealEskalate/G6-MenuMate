import 'package:file_picker/file_picker.dart';
import '../../domain/entities/resturant_registration.dart';

class ResturantModel extends ResturantRegistration {
  ResturantModel({
    required String id,
    required String resturant_name,
    required String resturant_phone,
    required PlatformFile verification_docs,
    PlatformFile? logo_image,
    PlatformFile? cover_image,
  }) : super(
          id: id,
          resturant_name: resturant_name,
          resturant_phone: resturant_phone,
          verification_docs: verification_docs,
          logo_image: logo_image,
          cover_image: cover_image,
        );

  factory ResturantModel.fromJson(Map<String, dynamic> json) {
    return ResturantModel(
      id: json['id'] ?? '',
      resturant_name: json['resturant_name'] ?? '',
      resturant_phone: json['resturant_phone'] ?? '',
      // For file fields, usually backend returns just URLs/paths → 
      // You can decide how to map them later
      verification_docs: PlatformFile(
        name: json['verification_docs'] ?? 'unknown',
        size: 0,
      ),
      logo_image: json['logo_image'] != null
          ? PlatformFile(name: json['logo_image'], size: 0)
          : null,
      cover_image: json['cover_image'] != null
          ? PlatformFile(name: json['cover_image'], size: 0)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resturant_name': resturant_name,
      'resturant_phone': resturant_phone,
      // File fields (logo_image, verification_docs, cover_image)
      // should be handled as Multipart uploads, not plain JSON
    };
  }
}
