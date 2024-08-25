import 'package:sqflite/sqflite.dart';

class TableDatabase {
  static final TableDatabase instance = TableDatabase._internal();

  static Database? _database;

  TableDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/restaurant.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${TableFields.tableName} (
        ${TableFields.id} ${TableFields.idType},
        ${TableFields.number} ${TableFields.intType},
        ${TableFields.title} ${TableFields.textType},
        ${TableFields.content} ${TableFields.textType},
        ${TableFields.createdTime} ${TableFields.textType}
      )
    ''');

    await db.execute('''
      CREATE TABLE ${CategoryFields.tableName} (
        ${CategoryFields.id} ${CategoryFields.idType},
        ${CategoryFields.name} ${CategoryFields.textType},
        ${CategoryFields.createdTime} ${CategoryFields.textType}
      )
    ''');

    await db.execute('''
      CREATE TABLE ${MenuFields.tableName} (
        ${MenuFields.id} ${MenuFields.idType},
        ${MenuFields.name} ${MenuFields.textType},
        ${MenuFields.description} ${MenuFields.textType},
        ${MenuFields.price} ${MenuFields.realType},
        ${MenuFields.createdTime} ${MenuFields.textType},
        ${MenuFields.categoryId} ${MenuFields.intType},
      FOREIGN KEY (${MenuFields.categoryId}) REFERENCES ${CategoryFields.tableName}(${CategoryFields.id})
    )
    ''');

    await db.execute('''
      CREATE TABLE ${OrderFields.tableName} (
        ${OrderFields.id} ${OrderFields.idType},
        ${OrderFields.customerId} ${OrderFields.textType},
        ${OrderFields.tableId} ${OrderFields.intType},
        ${OrderFields.orderDetails} ${OrderFields.textType},
        ${OrderFields.createdTime} ${OrderFields.textType},
        FOREIGN KEY (${OrderFields.tableId}) REFERENCES ${TableFields.tableName}(${TableFields.id})
      )
    ''');

    await db.execute('''
      CREATE TABLE ${CustomerFields.tableName} (
        ${CustomerFields.id} ${CustomerFields.idType},
        ${CustomerFields.name} ${CustomerFields.textType},
        ${CustomerFields.phone} ${CustomerFields.textType},
        ${CustomerFields.createdTime} ${CustomerFields.textType}
      )
    ''');
  }

  // Check the db

  Future<bool> hasTables() async {
    final db = await database; // Assuming you have a database getter
    final List<Map<String, dynamic>> result = await db.query(TableFields.tableName);
    return result.isNotEmpty;
  }

  Future<bool> hasCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(CategoryFields.tableName);
    return result.isNotEmpty;
  }

  Future<bool> hasMenus() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(MenuFields.tableName);
    return result.isNotEmpty;
  }
  
  // Crateing and Saving
  Future<TableModel> createTable(TableModel table) async {
    final db = await instance.database;
    final id = await db.insert(TableFields.tableName, table.toJson());
    return table.copy(id: id);
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    final db = await instance.database;
    final id = await db.insert(CategoryFields.tableName, category.toJson());
    return category.copy(id: id);
  }

  Future<MenuModel> createMenu(MenuModel menu) async {
    final db = await instance.database;
    final id = await db.insert(MenuFields.tableName, menu.toJson());
    return menu.copy(id: id);
  }

  // Read data

  Future<TableModel> readTable(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      TableFields.tableName,
      columns: TableFields.values,
      where: '${TableFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TableModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<TableModel>> readTablesAll() async {
    final db = await instance.database;
    const orderBy = '${TableFields.createdTime} DESC';
    final result = await db.query(TableFields.tableName, orderBy: orderBy);
    return result.map((json) => TableModel.fromJson(json)).toList();
  }

  Future<TableModel> readCategory(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      TableFields.tableName,
      columns: TableFields.values,
      where: '${TableFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TableModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<CategoryModel>> readCategoriesAll() async {
    final db = await instance.database;
    const orderBy = '${CategoryFields.createdTime} DESC';
    final result = await db.query(CategoryFields.tableName, orderBy: orderBy);
    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<MenuModel> readMenu(String name) async {
    final db = await instance.database;
    final maps = await db.query(
      MenuFields.tableName,
      columns: MenuFields.values,
      where: '${MenuFields.name} = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return MenuModel.fromJson(maps.first);
    } else {
      throw Exception('Menu $name not found');
    }
  }

  Future<List<MenuModel>> readMenussAll() async {
    final db = await instance.database;
    const orderBy = '${MenuFields.createdTime} DESC';
    final result = await db.query(MenuFields.tableName, orderBy: orderBy);
    return result.map((json) => MenuModel.fromJson(json)).toList();
  }

  Future<List<MenuModel>> readMenusByCategory(String categoryName) async {
    final db = await instance.database;

    // Get the category ID for the given category name
    final categoryMaps = await db.query(
      CategoryFields.tableName,
      columns: [CategoryFields.id],
      where: '${CategoryFields.name} = ?',
      whereArgs: [categoryName],
    );

    if (categoryMaps.isEmpty) {
      throw Exception('Category $categoryName not found');
    }

    final categoryId = categoryMaps.first[CategoryFields.id] as int;

    // Get the menus associated with this category ID
    final menuMaps = await db.query(
      MenuFields.tableName,
      columns: MenuFields.values,
      where: '${MenuFields.categoryId} = ?',
      whereArgs: [categoryId],
    );

    return menuMaps.map((json) => MenuModel.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

}

class TableFields {
  static const String tableName = 'tables';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String id = '_id';
  static const String title = 'title';
  static const String number = 'number';
  static const String content = 'content';
  static const String createdTime = 'created_time';

  static const List<String> values = [
    id,
    number,
    title,
    content,
    createdTime,
  ];
}

class CategoryFields {
  static const String tableName = 'categories';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String id = '_id';
  static const String name = 'title';
  static const String createdTime = 'created_time';

  static const List<String> values = [
    id,
    name,
    createdTime,
  ];
}

class MenuFields {
  static const String tableName = 'menus';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String realType = 'REAL NOT NULL';
  static const String id = '_id';
  static const String intType = 'INTEGER NOT NULL';
  static const String name = 'name';
  static const String description = 'description';
  static const String price = 'price';
  static const String createdTime = 'created_time';
  static const String categoryId = 'category_id';
  
  static const List<String> values = [
    id,
    name,
    description,
    price,
    createdTime,
    categoryId,
  ];
  
}

class OrderFields {
  static const String tableName = 'orders';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String id = '_id';
  static const String tableId = 'table_id';
  static const String customerId = 'custormer_id';
  static const String orderDetails = 'order_details';
  static const String createdTime = 'created_time';
}

class CustomerFields {
  static const String tableName = 'customers';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String id = '_id';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String createdTime = 'created_time';
}

class TableModel {
  final int? id;
  final int? number;
  final String title;
  final String content;
  final DateTime? createdTime;

  TableModel({
    this.id,
    this.number,
    required this.title,
    required this.content,
    this.createdTime,
  });

  // Convert a TableModel into a Map.
  Map<String, dynamic> toJson() {
    return {
      TableFields.number: number,
      TableFields.title: title,
      TableFields.content: content,
      TableFields.createdTime: createdTime?.toIso8601String(),
    };
  }

  // Create a TableModel from a Map.
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json[TableFields.id],
      number: json[TableFields.number],
      title: json[TableFields.title],
      content: json[TableFields.content],
      createdTime: json[TableFields.createdTime] != null
          ? DateTime.parse(json[TableFields.createdTime])
          : null,
    );
  }

  // Method to create a copy of the model with a new id.
  TableModel copy({int? id}) {
    return TableModel(
      id: id ?? this.id,
      number: number,
      title: title,
      content: content,
      createdTime: createdTime,
    );
  }
}

class CategoryModel {
  final int? id;
  final String name;
  final DateTime? createdTime;

  CategoryModel({
    this.id,
    required this.name,
    this.createdTime,
  });

  // Convert a TableModel into a Map.
  Map<String, dynamic> toJson() {
    return {
      CategoryFields.name: name,
      CategoryFields.createdTime: createdTime?.toIso8601String(),
    };
  }

  // Create a TableModel from a Map.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json[CategoryFields.id],
      name: json[CategoryFields.name],
      createdTime: json[CategoryFields.createdTime] != null
          ? DateTime.parse(json[CategoryFields.createdTime])
          : null,
    );
  }

  // Method to create a copy of the model with a new id.
  CategoryModel copy({int? id}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name,
      createdTime: createdTime,
    );
  }
}

class MenuModel {
  final int? id;
  final String name;
  final String description;
  final double price;
  final DateTime? createdTime;
  final int categoryId; // Add this field

  MenuModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId, // Update the constructor
    this.createdTime,
  });

  // Convert a MenuModel into a Map.
  Map<String, dynamic> toJson() {
    return {
      MenuFields.name: name,
      MenuFields.description: description,
      MenuFields.price: price,
      MenuFields.categoryId: categoryId, // Add to map
      MenuFields.createdTime: createdTime?.toIso8601String(),
    };
  }

  // Create a MenuModel from a Map.
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json[MenuFields.id],
      name: json[MenuFields.name],
      description: json[MenuFields.description],
      price: json[MenuFields.price],
      categoryId: json[MenuFields.categoryId], // Extract from map
      createdTime: json[MenuFields.createdTime] != null
          ? DateTime.parse(json[MenuFields.createdTime])
          : null,
    );
  }

  // Method to create a copy of the model with a new id.
  MenuModel copy({int? id}) {
    return MenuModel(
      id: id ?? this.id,
      name: name,
      description: description,
      price: price,
      categoryId: categoryId, // Copy the categoryId
      createdTime: createdTime,
    );
  }
}


class OrderModel {
  final int? id;
  final String customerId;
  final int tableId;
  final String orderDetails;
  final DateTime? createdTime;

  OrderModel({
    this.id,
    required this.customerId,
    required this.tableId,
    required this.orderDetails,
    this.createdTime,
  });

  // Convert an OrderModel into a Map.
  Map<String, dynamic> toJson() {
    return {
      OrderFields.customerId: customerId,
      OrderFields.tableId: tableId,
      OrderFields.orderDetails: orderDetails,
      OrderFields.createdTime: createdTime?.toIso8601String(),
    };
  }

  // Create an OrderModel from a Map.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json[OrderFields.id],
      customerId: json[OrderFields.customerId],
      tableId: json[OrderFields.tableId],
      orderDetails: json[OrderFields.orderDetails],
      createdTime: json[OrderFields.createdTime] != null
          ? DateTime.parse(json[OrderFields.createdTime])
          : null,
    );
  }
}

class CustomerModel {
  final int? id;
  final String name;
  final String phone;
  final DateTime? createdTime;

  CustomerModel({
    this.id,
    required this.name,
    required this.phone,
    this.createdTime,
  });

  // Convert a CustomerModel into a Map.
  Map<String, dynamic> toJson() {
    return {
      CustomerFields.name: name,
      CustomerFields.phone: phone,
      CustomerFields.createdTime: createdTime?.toIso8601String(),
    };
  }

  // Create a CustomerModel from a Map.
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json[CustomerFields.id],
      name: json[CustomerFields.name],
      phone: json[CustomerFields.phone],
      createdTime: json[CustomerFields.createdTime] != null
          ? DateTime.parse(json[CustomerFields.createdTime])
          : null,
    );
  }
}
