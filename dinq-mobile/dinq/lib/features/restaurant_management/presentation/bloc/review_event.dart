import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadReviewsEvent extends ReviewEvent {
  final String itemId;

  const LoadReviewsEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class LoadUserImagesEvent extends ReviewEvent {
  final String slug;

  const LoadUserImagesEvent(this.slug);

  @override
  List<Object?> get props => [slug];
}
