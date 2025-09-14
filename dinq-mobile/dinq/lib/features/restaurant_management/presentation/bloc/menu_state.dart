import 'package:equatable/equatable.dart';

import '../../domain/entities/menu.dart';
import '../../domain/entities/qr.dart';
import '../../domain/entities/restaurant.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial();
}

class MenuLoading extends MenuState {
  const MenuLoading();
}

class MenuLoaded extends MenuState {
  final Menu menu;
  final Restaurant restaurant;

  const MenuLoaded({required this.menu, required this.restaurant});

  @override
  List<Object?> get props => [menu, restaurant];
}

class MenuCreateLoaded extends MenuState {
  final dynamic menuCreateModel;

  const MenuCreateLoaded(this.menuCreateModel);

  @override
  List<Object?> get props => [menuCreateModel];
}

class MenuActionSuccess extends MenuState {
  final String message;

  const MenuActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class QrLoaded extends MenuState {
  final Qr qr;

  const QrLoaded(this.qr);

  @override
  List<Object?> get props => [qr];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
