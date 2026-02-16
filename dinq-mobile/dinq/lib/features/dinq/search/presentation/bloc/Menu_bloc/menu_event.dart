import 'package:equatable/equatable.dart';


abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props=>[];
}

class LoadListOfMenus extends MenuEvent {
  final String slug;
  const LoadListOfMenus(this.slug);
  @override
  List<Object?> get props => [slug];
}


