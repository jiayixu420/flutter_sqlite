import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/menu_bloc.dart'; // Create a similar bloc as for Table and Category
import './bloc/menu_event.dart';
import './bloc/menu_state.dart';

class MenuListScreen extends StatelessWidget {
  final String categoryName;

  const MenuListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menus')),
      body: BlocProvider(
        create: (context) => MenuBloc()..add(LoadMenusByCategory(categoryName)),
        child: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MenuLoadSuccess) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                ),
                itemCount: state.menus.length,
                itemBuilder: (context, index) {
                  final menu = state.menus[index];
                  return Card(
                    child: Center(
                      child: Column(
                        children: [
                          Text(menu.name),
                          Text('\$${menu.price.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is MenuLoadFailure) {
              return Center(child: Text('Failed to load menus: ${state.error}'));
            }
            return Container();
          },
        ),
      ),
    );
  }
}
