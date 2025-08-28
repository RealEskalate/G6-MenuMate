import 'dart:convert';

import 'package:dinq/features/restaurant_management/domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userAvatar,
    super.rating,
    super.comment,
    super.images,
    required super.like,
    required super.disLike,
    required super.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data) => ReviewModel(
    id: data['id'] ?? '',
    userId: data['userId'] ?? '',
    userName: data['userName'] ?? '',
    userAvatar: data['userAvatar'] ?? '',
    rating: (data['rating'] as num?)?.toDouble(),
    comment: data['comment'],
    images: (data['images'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    like: data['like'] ?? 0,
    disLike: data['disLike'] ?? 0,
    createdAt: DateTime.parse(
      data['createdAt'] ?? DateTime.now().toIso8601String(),
    ),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
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
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    List<String>? images,
    int? like,
    int? disLike,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
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
}
