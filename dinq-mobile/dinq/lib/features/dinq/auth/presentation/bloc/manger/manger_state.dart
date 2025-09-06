// lib/features/DineQ_App/auth/presentation/bloc/auth/auth_state.dart

import 'package:equatable/equatable.dart';

import '../../../data/models/resturant_model.dart';
import '../../Pages/manger_registration.dart';


abstract class MangerState extends Equatable {
  const MangerState();

  @override
  List<Object> get props => [];
}

class MangerInitial extends MangerState {}

class MangerLoading extends MangerState{}

class MangerRegistered extends MangerState {
  final ResturantModel manger;

  const MangerRegistered({required this.manger});

  @override
  List<Object> get props => [manger];
}
class MangerError extends MangerState {
  final String message;

  const MangerError({required this.message});

  @override
  List<Object> get props => [message];
}