import 'dart:convert';

import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.slug,
    required super.restaurantName,
    required super.managerId,
    required super.restaurantPhone,
    super.about,
    super.tags,
    super.logoImage,
    super.coverImage,
    super.verificationDocs,
    required super.previousSlugs,
    required super.verificationStatus,
    required super.averageRating,
    required super.viewCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> data) {
    List<String> toStringList(dynamic v) {
      if (v == null) return <String>[];
      if (v is List) {
        return v
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return <String>[];
    }

    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      if (v is num) return v.toDouble();
      return 0.0;
    }

    DateTime toDateTime(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return RestaurantModel(
      id: data['id']?.toString() ?? '',
      slug: data['slug']?.toString() ?? '',
      restaurantName: data['name']?.toString() ?? '',
      managerId: data['manager_id']?.toString() ?? '',
      restaurantPhone: data['phone']?.toString() ?? '',
      about: data['about']?.toString(),
      tags: data['tags'] == null ? null : toStringList(data['tags']),
      logoImage: data['logo_image']?.toString(),
      coverImage: data['cover_image']?.toString(),
      verificationDocs: data['verification_docs']?.toString(),
      previousSlugs: toStringList(data['previous_slugs']),
      verificationStatus: data['verification_status']?.toString() ?? '',
      averageRating: toDouble(data['average_rating']),
      viewCount: toDouble(data['view_count']),
      createdAt: toDateTime(data['created_at']),
      updatedAt: toDateTime(data['updated_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'slug': slug,
    'restaurant_name': restaurantName,
    'manager_id': managerId,
    'restaurant_phone': restaurantPhone,
    'about': about,
    'tags': tags,
    'logo_image': logoImage,
    'cover_image': coverImage,
    'verification_docs': verificationDocs,
    'previous_slugs': previousSlugs,
    'verification_status': verificationStatus,
    'average_rating': averageRating,
    'view_count': viewCount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory RestaurantModel.fromJson(String data) {
    return RestaurantModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  RestaurantModel copyWith({
    String? id,
    String? slug,
    String? restaurantName,
    String? managerId,
    String? restaurantPhone,
    String? about,
    List<String>? tags,
    String? logoImage,
    String? coverImage,
    String? verificationDocs,
    List<String>? previousSlugs,
    String? verificationStatus,
    double? averageRating,
    double? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      restaurantName: restaurantName ?? this.restaurantName,
      managerId: managerId ?? this.managerId,
      restaurantPhone: restaurantPhone ?? this.restaurantPhone,
      about: about ?? this.about,
      tags: tags ?? this.tags,
      logoImage: logoImage ?? this.logoImage,
      coverImage: coverImage ?? this.coverImage,
      verificationDocs: verificationDocs ?? this.verificationDocs,
      previousSlugs: previousSlugs ?? this.previousSlugs,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      averageRating: averageRating ?? this.averageRating,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool get stringify => true;

  Restaurant toEntity() => this;

  factory RestaurantModel.fromEntity(Restaurant entity) => RestaurantModel(
    id: entity.id,
    slug: entity.slug,
    restaurantName: entity.restaurantName,
    managerId: entity.managerId,
    restaurantPhone: entity.restaurantPhone,
    about: entity.about,
    tags: entity.tags,
    logoImage: entity.logoImage,
    coverImage: entity.coverImage,
    verificationDocs: entity.verificationDocs,
    previousSlugs: entity.previousSlugs,
    verificationStatus: entity.verificationStatus,
    averageRating: entity.averageRating,
    viewCount: entity.viewCount,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
