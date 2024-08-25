import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/table_bloc.dart';
import './bloc/table_event.dart';
import './bloc/table_state.dart';
import '../db/table_database.dart';
import 'category_list_screen.dart'; // Import the category screen

class TableListScreen extends StatelessWidget {
  const TableListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tables')),
      body: BlocProvider(
        create: (context) => TableBloc(TableDatabase.instance)..add(LoadTables()),  // Pass the TableDatabase instance here
        child: BlocBuilder<TableBloc, TableState>(
          builder: (context, state) {
            if (state is TableLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TableLoadSuccess) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 10
                ),
                itemCount: state.tables.length,
                itemBuilder: (context, index) {
                  final table = state.tables[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryListScreen(),
                        ),
                      );
                    },
                    child:  Center(
                      child: childItem(context, table.title, 'T${index+1}'),
                    ),
                  );
                },
              );
            } else if (state is TableLoadFailure) {
              return Center(child: Text('Failed to load tables: ${state.error}'));
            }
            return Container();
          },
        ),
      ),
    );

  }

  Widget childItem(BuildContext context, String tableName, String tableNumber) {
  return Container(
    height: 80,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      border: Border.all(),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center widgets vertically
      children: [
        Text(
          tableNumber,
          style: TextStyle(fontSize: 20),
        ),
        Text(
          tableName,
        ),
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            color: Colors.green,
          ),
          child: const Text(
            '0/4',
            textAlign: TextAlign.center,
          ),
        )
      ],
    ),
  );
}

}
