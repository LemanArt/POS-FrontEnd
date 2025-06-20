import 'package:flutter_pos_app/data/models/requests/order_request_model.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../presentation/home/models/order_item.dart';

class ProductLocalDatasource {
  ProductLocalDatasource._init();

  static final ProductLocalDatasource instance = ProductLocalDatasource._init();

  final String tableProducts = 'products';

  static Database? _database;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        name TEXT,
        price INTEGER,
        stock INTEGER,
        image TEXT,
        category TEXT,
        is_best_seller INTEGER,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nominal INTEGER,
        payment_method TEXT,
        total_item INTEGER,
        id_kasir INTEGER,
        nama_kasir TEXT,
        transaction_time TEXT,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');
  }

  //save order
  Future<int> saveOrder(OrderModel order) async {
    final db = await instance.database;
    int id = await db.insert('orders', order.toMapForLocal());
    for (var orderItem in order.orders) {
      await db.insert('order_items', orderItem.toMapForLocal(id));
    }
    return id;
  }

  //get order by isSync = 0
  Future<List<OrderModel>> getOrderByIsSync() async {
    final db = await instance.database;
    final result = await db.query('orders', where: 'is_sync = 0');

    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get order item by id order
  Future<List<OrderItemModel>> getOrderItemByOrderIdLocal(int idOrder) async {
    final db = await instance.database;
    final result = await db
        .query('order_items', where: 'id_order = ?', whereArgs: [idOrder]);

    // Gunakan fromMapLocal untuk memetakan data dari database
    return result.map((e) => OrderItemModel.fromMapLocal(e)).toList();
  }

  //update isSync order by id
  Future<int> updateIsSyncOrderById(int id) async {
    final db = await instance.database;
    return await db.update('orders', {'is_sync': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  //get all orders
  Future<List<OrderModel>> getAllOrder() async {
    final db = await instance.database;
    final result = await db.query('orders', orderBy: 'id DESC');
    print('Orders from DB: $result'); // Cek apakah hasil query sudah sesuai
    final r = result.map((e) => OrderModel.fromLocalMap(e)).toList();
    for (int i = 0; i < r.length; i++) {
      final model = r[i];
      final orders = await getOrderItemByOrderId(model.id ?? 0);
      r[i].orders.addAll(orders);
    }
    return r;
  }

  //get order item by id order
  Future<List<OrderItem>> getOrderItemByOrderId(int idOrder) async {
    final db = await instance.database;
    final result = await db.query('order_items', where: 'id_order = $idOrder');
    final resultProducts = <Product>[];
    for (int i = 0; i < result.length; i++) {
      final idProduct = result[i]["id_product"];
      final products = await getProductById(idProduct as int);
      if (products.isNotEmpty) {
        resultProducts.add(products.first);
      }
    }
    return List.generate(result.length, (i) {
      return OrderItem(
          product: resultProducts[i],
          quantity: int.tryParse("${result[i]["quantity"]}") ?? 0);
    });
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('pos13.db');
    return _database!;
  }

  //remove all data product
  Future<void> removeAllProduct() async {
    final db = await instance.database;
    await db.delete(tableProducts);
  }

  //insert data product from list product
  Future<void> insertAllProduct(List<Product> products) async {
    final db = await instance.database;
    for (var product in products) {
      await db.insert(tableProducts, product.toLocalMap());
    }
  }

  //isert data product
  Future<Product> insertProduct(Product product) async {
    final db = await instance.database;
    int id = await db.insert(tableProducts, product.toMap());
    return product.copyWith(id: id);
  }

  //get all data product
  Future<List<Product>> getAllProduct() async {
    final db = await instance.database;
    final result = await db.query(tableProducts);

    return result.map((e) => Product.fromMap(e)).toList();
  }

  //get product by id
  Future<List<Product>> getProductById(int idProduct) async {
    final db = await instance.database;
    final result = await db.query(tableProducts,
        where: 'product_id = $idProduct', limit: 1);
    return result.map((e) {
      return Product.fromMap(e);
    }).toList();
  }
}
