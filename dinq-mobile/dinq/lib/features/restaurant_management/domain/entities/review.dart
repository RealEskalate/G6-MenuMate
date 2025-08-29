import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String itemId;
  final String userId;
  /// TODO: I will use only user ids
  final String userName;
  final String userAvatar;
  final double? rating;
  final String? comment;
  final List<String>? images;
  final int like;
  final int disLike;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.images,
    required this.like,
    required this.disLike,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}
