import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  // TODO: add average rating field.
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String image;
  final bool isActive;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.image,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id];
}
