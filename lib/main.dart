import 'dart:math';

import 'package:flutter/material.dart';
import 'package:restaurant/db/table_database.dart';
import 'package:restaurant/table/table_list_screen.dart';
import 'package:faker/faker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  double getRandomDecimal(double min, double max) {
    final random = Random();
    return min + random.nextDouble() * (max - min);
  }

  Future<void> insertFakeData() async {
    final db = TableDatabase.instance;

    // Check if the database is empty
    bool hasData = await db.hasTables() || await db.hasCategories() || await db.hasMenus();

    if (hasData) {
      print('Database already contains data. No need to insert fake data.');
      return;
    }

    // Create fake tables
    for (int i = 1; i <= 10; i++) {
      await db.createTable(
        TableModel(
          number: i,
          title: faker.lorem.word(),
          content: faker.lorem.sentence(),
          createdTime: DateTime.now(),
        ),
      );
    }

    // Create fake categories
    for (int i = 1; i <= 5; i++) {
      await db.createCategory(
        CategoryModel(
          name: faker.food.cuisine(),
          createdTime: DateTime.now(),
        ),
      );
    }

    // Create fake menus
    for (int i = 1; i <= 20; i++) {
      await db.createMenu(
        MenuModel(
          name: faker.food.dish(),
          description: faker.lorem.sentence(),
          price: getRandomDecimal(10, 100),
          categoryId: faker.randomGenerator.integer(5, min: 1), // Random category ID
          createdTime: DateTime.now(),
        ),
      );
    }

    print('Fake data inserted successfully.');
  }

  @override
  Widget build(BuildContext context) {
    // Ensure that the data is inserted before the app starts
    insertFakeData();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TableListScreen(),
    );
  }
}
