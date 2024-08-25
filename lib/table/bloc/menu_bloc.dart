import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/db/table_database.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final TableDatabase tableDatabase = TableDatabase.instance;

  MenuBloc() : super(MenuInitial()) {
    // Register the event handler for LoadMenusByCategory
    on<LoadMenusByCategory>(_onLoadMenusByCategory);
  }

  Future<void> _onLoadMenusByCategory(LoadMenusByCategory event, Emitter<MenuState> emit) async {
    emit(MenuLoadInProgress());
    try {
      final menus = await tableDatabase.readMenusByCategory(event.categoryName);
      emit(MenuLoadSuccess(menus));
    } catch (e) {
      emit(MenuLoadFailure(e.toString()));
    }
  }
}
