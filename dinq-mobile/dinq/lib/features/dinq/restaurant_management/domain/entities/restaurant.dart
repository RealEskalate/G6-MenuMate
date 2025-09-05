import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String slug;
  final String restaurantName;
  final String managerId;
  final String restaurantPhone;
  final String? about;
  final List<String>? tags;
  final String? logoImage;
  final String? coverImage;
  final String? verificationDocs;
  final List<String> previousSlugs;
  final String verificationStatus;
  final double averageRating;
  final double viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Restaurant({
    required this.id,
    required this.slug,
    required this.restaurantName,
    required this.managerId,
    required this.restaurantPhone,
    this.about,
    this.tags,
    this.logoImage,
    this.coverImage,
    this.verificationDocs,
    required this.previousSlugs,
    required this.verificationStatus,
    required this.averageRating,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id];
}
