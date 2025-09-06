import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

class ResturantRegistration extends Equatable {
  final String id;
  final String resturant_name;
  final String resturant_phone;
  final PlatformFile? logo_image;
  final PlatformFile verification_docs;
  final PlatformFile?  cover_image;
  ResturantRegistration({
    required this.id,
    required this.resturant_name,
    required this.resturant_phone,
    required this.verification_docs,
    this.cover_image,
    this.logo_image,
  });
  @override
  List<Object> get props => [
    id,
    resturant_name,
    resturant_phone,
    verification_docs,
  ];
}
