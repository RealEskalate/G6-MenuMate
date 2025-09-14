import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/review/get_reviews.dart';
import '../../domain/usecases/review/get_user_images.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetReviews getReviews;
  final GetUserImages getUserImages;

  ReviewBloc({
    required this.getReviews,
    required this.getUserImages,
  }) : super(const ReviewInitial()) {
    on<LoadReviewsEvent>(_onLoadReviews);
    on<LoadUserImagesEvent>(_onLoadUserImages);
  }

  Future<void> _onLoadReviews(
    LoadReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await getReviews(event.itemId);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(ReviewsLoaded(reviews)),
    );
  }

  Future<void> _onLoadUserImages(
    LoadUserImagesEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await getUserImages(event.slug);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (images) => emit(UserImagesLoaded(images)),
    );
  }
}
