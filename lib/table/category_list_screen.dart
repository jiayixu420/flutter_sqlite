import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/category_bloc.dart'; // Import the BLoC file
import './bloc/category_event.dart'; // Import the Event file
import './bloc/category_state.dart'; // Import the State file
import 'menu_list_screen.dart'; // Import the menu screen

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: BlocProvider(
        create: (context) => CategoryBloc()..add(LoadCategories()),
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoadSuccess) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                ),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuListScreen(categoryName: category.name),
                        ),
                      );
                    },
                    child: Card(
                      child: Center(
                        child: Text(category.name),
                      ),
                    ),
                  );
                },
              );
            } else if (state is CategoryLoadFailure) {
              return Center(child: Text('Failed to load categories: ${state.error}'));
            }
            return Container();
          },
        ),
      ),
    );
  }
}
