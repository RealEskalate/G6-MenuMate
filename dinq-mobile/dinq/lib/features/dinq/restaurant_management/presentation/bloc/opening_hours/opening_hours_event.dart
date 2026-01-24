import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class OpeningHoursEvent extends Equatable {
  const OpeningHoursEvent();

  @override
  List<Object?> get props => [];
}

class LoadOpeningHours extends OpeningHoursEvent {
  const LoadOpeningHours();
}

class UpdateOpeningTime extends OpeningHoursEvent {
  final TimeOfDay time;
  final int dayIndex;

  const UpdateOpeningTime(this.time, this.dayIndex);

  @override
  List<Object?> get props => [time, dayIndex];
}

class UpdateClosingTime extends OpeningHoursEvent {
  final TimeOfDay time;
  final int dayIndex;

  const UpdateClosingTime(this.time, this.dayIndex);

  @override
  List<Object?> get props => [time, dayIndex];
}

class AddSpecialDay extends OpeningHoursEvent {
  final DateTime date;
  final String title;
  final String status;

  const AddSpecialDay({
    required this.date,
    required this.title,
    required this.status,
  });

  @override
  List<Object?> get props => [date, title, status];
}

class RemoveSpecialDay extends OpeningHoursEvent {
  final int index;

  const RemoveSpecialDay(this.index);

  @override
  List<Object?> get props => [index];
}

class SaveOpeningHours extends OpeningHoursEvent {
  const SaveOpeningHours();
}
