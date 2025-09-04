import 'dart:convert';

import '../../domain/entities/review.dart';
import '../model/user_model.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.itemId,
    required super.user,
    required super.rating,
    required super.comment,
    super.images,
    required super.like,
    required super.disLike,
    required super.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data) {
    final userData =
        data['user'] as Map<String, dynamic>? ??
        (data['userInfo'] as Map<String, dynamic>?) ??
        {};

    return ReviewModel(
      id: data['id'] ?? '',
      itemId: data['itemId'] ?? data['item_id'] ?? '',
      user: UserModel.fromMap(userData),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: (data['comment'] ?? data['message'] ?? '') as String,
      images: (data['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      like: data['like'] ?? 0,
      disLike: data['disLike'] ?? data['dis_like'] ?? 0,
      createdAt: DateTime.parse(
        data['createdAt'] ??
            data['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'itemId': itemId,
    'user': (user as UserModel).toMap(),
    'rating': rating,
    'comment': comment,
    'images': images,
    'like': like,
    'disLike': disLike,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ReviewModel.fromJson(String data) {
    return ReviewModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  ReviewModel copyWith({
    String? id,
    String? itemId,
    UserModel? user,
    double? rating,
    String? comment,
    List<String>? images,
    int? like,
    int? disLike,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      user: user ?? (this.user as UserModel),
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      like: like ?? this.like,
      disLike: disLike ?? this.disLike,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool get stringify => true;

  Review toEntity() => this;

  factory ReviewModel.fromEntity(Review entity) => ReviewModel(
    id: entity.id,
    itemId: entity.itemId,
    user: UserModel.fromEntity(entity.user),
    rating: entity.rating,
    comment: entity.comment,
    images: entity.images,
    like: entity.like,
    disLike: entity.disLike,
    createdAt: entity.createdAt,
  );
}
