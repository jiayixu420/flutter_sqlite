import 'package:equatable/equatable.dart';
import 'package:restaurant/db/table_database.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoadInProgress extends CategoryState {}

class CategoryLoadSuccess extends CategoryState {
  final List<CategoryModel> categories;

  const CategoryLoadSuccess(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryLoadFailure extends CategoryState {
  final String error;

  const CategoryLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
