import 'package:equatable/equatable.dart';
import 'package:restaurant/db/table_database.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object?> get props => [];
}

class TableInitial extends TableState {}

class TableLoadInProgress extends TableState {}

class TableLoadSuccess extends TableState {
  final List<TableModel> tables;

  const TableLoadSuccess(this.tables);

  @override
  List<Object?> get props => [tables];
}

class TableLoadFailure extends TableState {
  final String error;

  const TableLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
