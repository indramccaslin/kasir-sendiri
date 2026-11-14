import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final p = join(dir.path, 'kasir_sendiri.db');
    return await openDatabase(
      p,
      version: 2,
      onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT, category TEXT, price REAL, retail_price REAL,
          base_price REAL DEFAULT 0, stock INTEGER DEFAULT 0, barcode TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE customers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT, phone TEXT, address TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT, customer_id INTEGER, subtotal REAL, tax REAL,
          shipping REAL, total REAL, cash REAL, change REAL, status TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE sale_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER, product_id INTEGER, qty INTEGER, price REAL,
          FOREIGN KEY(sale_id) REFERENCES sales(id)
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE products ADD COLUMN base_price REAL DEFAULT 0');
        }
      },
    );
  }

  Future<int> insertProduct(Product p) async {
    final d = await db;
    return await d.insert('products', p.toMap());
  }

  Future<List<Product>> getProducts() async {
    final d = await db;
    final maps = await d.query('products', orderBy: 'name ASC');
    return maps.map(Product.fromMap).toList();
  }

  Future<int> updateProduct(Product p) async {
    final d = await db;
    return await d.update('products', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> updateProductStock(int id, int qty) async {
    final d = await db;
    return await d.rawUpdate('UPDATE products SET stock = stock - ? WHERE id = ?', [qty, id]);
  }

  Future<int> deleteProduct(int id) async {
    final d = await db;
    return await d.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertCustomer(Customer c) async {
    final d = await db;
    return await d.insert('customers', c.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    final d = await db;
    final maps = await d.query('customers', orderBy: 'name ASC');
    return maps.map(Customer.fromMap).toList();
  }

  Future<int> insertSale(Sale s) async {
    final d = await db;
    return await d.transaction((txn) async {
      final id = await txn.insert('sales', s.toMap());
      for (final it in s.items) {
        await txn.insert('sale_items', {
          'sale_id': id,
          'product_id': it.product.id,
          'qty': it.qty,
          'price': it.price,
        });
        await txn.rawUpdate('UPDATE products SET stock = stock - ? WHERE id = ?', [it.qty, it.product.id]);
      }
      return id;
    });
  }

  Future<List<Sale>> getSales() async {
    final d = await db;
    final maps = await d.query('sales', orderBy: 'date DESC');
    return maps.map(Sale.fromMap).toList();
  }

  Future<double> dailyTotal(DateTime day) async {
    final d = await db;
    final start = DateTime(day.year, day.month, day.day).toIso8601String();
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59).toIso8601String();
    final maps = await d.query('sales', where: 'date BETWEEN ? AND ?', whereArgs: [start, end]);
    double total = 0;
    for (final m in maps) {
      total += ((m['total'] ?? 0) as num).toDouble();
    }
    return total;
  }
}
