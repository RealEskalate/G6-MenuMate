import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SpecialDay {
  final DateTime date;
  final String title;
  final String status;

  SpecialDay({required this.date, required this.title, required this.status});
}

abstract class OpeningHoursState extends Equatable {
  const OpeningHoursState();

  @override
  List<Object?> get props => [];
}

class OpeningHoursInitial extends OpeningHoursState {}

class OpeningHoursLoading extends OpeningHoursState {}

class OpeningHoursLoaded extends OpeningHoursState {
  final List<TimeOfDay?> openingTimes;
  final List<TimeOfDay?> closingTimes;
  final List<SpecialDay> specialDays;
  final bool hasChanges;

  const OpeningHoursLoaded({
    required this.openingTimes,
    required this.closingTimes,
    required this.specialDays,
    this.hasChanges = false,
  });

  OpeningHoursLoaded copyWith({
    List<TimeOfDay?>? openingTimes,
    List<TimeOfDay?>? closingTimes,
    List<SpecialDay>? specialDays,
    bool? hasChanges,
  }) {
    return OpeningHoursLoaded(
      openingTimes: openingTimes ?? this.openingTimes,
      closingTimes: closingTimes ?? this.closingTimes,
      specialDays: specialDays ?? this.specialDays,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  List<Object?> get props => [
    openingTimes,
    closingTimes,
    specialDays,
    hasChanges,
  ];
}

class OpeningHoursSaving extends OpeningHoursState {}

class OpeningHoursSaved extends OpeningHoursState {}

class OpeningHoursError extends OpeningHoursState {
  final String message;

  const OpeningHoursError(this.message);

  @override
  List<Object?> get props => [message];
}
