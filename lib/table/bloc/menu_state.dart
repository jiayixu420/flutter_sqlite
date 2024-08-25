// menu_state.dart

import 'package:restaurant/db/table_database.dart';

abstract class MenuState {}

class MenuInitial extends MenuState {}

class MenuLoadInProgress extends MenuState {}

class MenuLoadSuccess extends MenuState {
  final List<MenuModel> menus;

  MenuLoadSuccess(this.menus);
}

class MenuLoadFailure extends MenuState {
  final String error;

  MenuLoadFailure(this.error);
}
