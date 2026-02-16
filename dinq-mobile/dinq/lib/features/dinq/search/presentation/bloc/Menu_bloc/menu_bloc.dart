import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../restaurant_management/domain/usecases/restaurant/get_list_menus.dart';
import '../HomeBloc/home_event.dart' hide LoadListOfMenus;
import 'menu_event.dart';
import 'menu_state.dart';


class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetListMenus getListMenus;

 MenuBloc(
      {
      required this.getListMenus})
      : super(const MenuState()) {

    on<LoadListOfMenus>(_onLoadListOfMenus);
  }

Future<void> _onLoadListOfMenus(
      LoadListOfMenus event, Emitter<MenuState> emit) async {
    emit(state.copyWith(status: MenuStatus.loading));
    final params = GetListMenusParams(slug: event.slug);
    final result = await getListMenus(params);
    result.fold((failure) {
      emit(state.copyWith(
        status: MenuStatus.error,
        errorMessage: failure.message,
      ));
    }, (menus) {
      if (menus.isEmpty) {
        emit(state.copyWith(status: MenuStatus.empty));
      } else {
        emit(state.copyWith(status: MenuStatus.success, menus:menus));
      }
    });
}
  }