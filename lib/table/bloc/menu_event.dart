// menu_event.dart

import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenusByCategory extends MenuEvent {
  final String categoryName;

  const LoadMenusByCategory(this.categoryName);
}
