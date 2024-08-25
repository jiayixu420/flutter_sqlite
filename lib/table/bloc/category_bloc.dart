import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/db/table_database.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final TableDatabase tableDatabase = TableDatabase.instance;

  CategoryBloc() : super(CategoryInitial()) {
    // Register the event handler for LoadCategories
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoadInProgress());
    try {
      final categories = await tableDatabase.readCategoriesAll(); // Fetch all categories
      emit(CategoryLoadSuccess(categories));
    } catch (e) {
      emit(CategoryLoadFailure(e.toString()));
    }
  }
}
