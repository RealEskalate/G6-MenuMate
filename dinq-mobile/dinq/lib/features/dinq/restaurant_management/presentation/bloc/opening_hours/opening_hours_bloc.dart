import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'opening_hours_event.dart';
import 'opening_hours_state.dart';

class OpeningHoursBloc extends Bloc<OpeningHoursEvent, OpeningHoursState> {
  OpeningHoursBloc() : super(OpeningHoursInitial()) {
    on<LoadOpeningHours>(_onLoadOpeningHours);
    on<UpdateOpeningTime>(_onUpdateOpeningTime);
    on<UpdateClosingTime>(_onUpdateClosingTime);
    on<AddSpecialDay>(_onAddSpecialDay);
    on<RemoveSpecialDay>(_onRemoveSpecialDay);
    on<SaveOpeningHours>(_onSaveOpeningHours);
  }

  void _onLoadOpeningHours(
    LoadOpeningHours event,
    Emitter<OpeningHoursState> emit,
  ) async {
    emit(OpeningHoursLoading());
    try {
      // In a real app, you would load data from a repository
      // For this example, we'll use dummy data
      final openingTimes = List<TimeOfDay?>.filled(7, null);
      final closingTimes = List<TimeOfDay?>.filled(7, null);

      // Set default times for weekdays (Monday to Friday)
      for (int i = 0; i < 5; i++) {
        openingTimes[i] = const TimeOfDay(hour: 9, minute: 0);
        closingTimes[i] = const TimeOfDay(hour: 17, minute: 0);
      }

      // Set default times for weekend (Saturday and Sunday)
      openingTimes[5] = const TimeOfDay(hour: 10, minute: 0);
      closingTimes[5] = const TimeOfDay(hour: 15, minute: 0);

      // Sunday closed
      openingTimes[6] = null;
      closingTimes[6] = null;

      emit(
        OpeningHoursLoaded(
          openingTimes: openingTimes,
          closingTimes: closingTimes,
          specialDays: const [],
        ),
      );
    } catch (e) {
      emit(OpeningHoursError(e.toString()));
    }
  }

  void _onUpdateOpeningTime(
    UpdateOpeningTime event,
    Emitter<OpeningHoursState> emit,
  ) {
    final currentState = state;
    if (currentState is OpeningHoursLoaded) {
      final updatedOpeningTimes = List<TimeOfDay?>.from(
        currentState.openingTimes,
      );
      updatedOpeningTimes[event.dayIndex] = event.time;

      emit(
        currentState.copyWith(
          openingTimes: updatedOpeningTimes,
          hasChanges: true,
        ),
      );
    }
  }

  void _onUpdateClosingTime(
    UpdateClosingTime event,
    Emitter<OpeningHoursState> emit,
  ) {
    final currentState = state;
    if (currentState is OpeningHoursLoaded) {
      final updatedClosingTimes = List<TimeOfDay?>.from(
        currentState.closingTimes,
      );
      updatedClosingTimes[event.dayIndex] = event.time;

      emit(
        currentState.copyWith(
          closingTimes: updatedClosingTimes,
          hasChanges: true,
        ),
      );
    }
  }

  void _onAddSpecialDay(AddSpecialDay event, Emitter<OpeningHoursState> emit) {
    final currentState = state;
    if (currentState is OpeningHoursLoaded) {
      final updatedSpecialDays = List<SpecialDay>.from(
        currentState.specialDays,
      );
      updatedSpecialDays.add(
        SpecialDay(date: event.date, title: event.title, status: event.status),
      );

      emit(
        currentState.copyWith(
          specialDays: updatedSpecialDays,
          hasChanges: true,
        ),
      );
    }
  }

  void _onRemoveSpecialDay(
    RemoveSpecialDay event,
    Emitter<OpeningHoursState> emit,
  ) {
    final currentState = state;
    if (currentState is OpeningHoursLoaded) {
      final updatedSpecialDays = List<SpecialDay>.from(
        currentState.specialDays,
      );
      if (event.index >= 0 && event.index < updatedSpecialDays.length) {
        updatedSpecialDays.removeAt(event.index);

        emit(
          currentState.copyWith(
            specialDays: updatedSpecialDays,
            hasChanges: true,
          ),
        );
      }
    }
  }

  void _onSaveOpeningHours(
    SaveOpeningHours event,
    Emitter<OpeningHoursState> emit,
  ) async {
    final currentState = state;
    if (currentState is OpeningHoursLoaded) {
      emit(OpeningHoursSaving());
      try {
        // In a real app, you would save data to a repository
        // For this example, we'll just simulate a delay
        await Future.delayed(const Duration(seconds: 1));

        emit(OpeningHoursSaved());
        emit(currentState.copyWith(hasChanges: false));
      } catch (e) {
        emit(OpeningHoursError(e.toString()));
        emit(currentState);
      }
    }
  }
}
