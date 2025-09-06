// Bloc
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repository/resturant_reg_repo.dart';
import 'manger__event.dart';
import 'manger_state.dart';

class MangerBloc extends Bloc<MangerEvent, MangerState> {
  final ResturantRegRepo _repo;

  MangerBloc({required ResturantRegRepo repo})
      : _repo = repo,
        super(MangerInitial()) {
    on<ResturantEvent>(_onRegisterManger);
  }

  Future<void> _onRegisterManger(
    ResturantEvent event,
    Emitter<MangerState> emit,
  ) async {
    emit(MangerLoading());
    try {
      final resturant = await _repo.registerRestaurant(
        resturantname: event.resturant_name,
        returantphone: event.resturant_phone,
        verification_docs: event.verification_docs,
        logo_image: event.logo_image,
        cover_image: event.cover_image,
      );
      emit(MangerRegistered(manger: resturant));
    } catch (e) {
      emit(MangerError(message: e.toString()));
    }
  }
}
