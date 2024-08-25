import 'package:flutter_bloc/flutter_bloc.dart';
import 'table_event.dart';
import 'table_state.dart';
import '../../db/table_database.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TableDatabase tableDatabase;

  TableBloc(this.tableDatabase) : super(TableInitial()) {
    on<LoadTables>(_onLoadTables); // Register the event handler
  }

  void _onLoadTables(LoadTables event, Emitter<TableState> emit) async {
    emit(TableLoadInProgress());
    try {
      final tables = await tableDatabase.readTablesAll();
      emit(TableLoadSuccess(tables));
    } catch (e) {
      emit(TableLoadFailure(e.toString()));
    }
  }
}
