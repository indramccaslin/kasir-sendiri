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
    return openDatabase(
      p,
      version: 3,
      onCreate: (db, version) async => _create(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        for (final t in ['sale_items', 'sales', 'products', 'transactions', 'customers']) {
          await db.execute('DROP TABLE IF EXISTS $t');
        }
        await _create(db);
      },
    );
  }

  Future<void> _create(Database db) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        base_price REAL NOT NULL DEFAULT 0,
        price REAL NOT NULL DEFAULT 0,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        product_name TEXT NOT NULL,
        target TEXT NOT NULL,
        qty INTEGER NOT NULL DEFAULT 1,
        base_price REAL NOT NULL DEFAULT 0,
        price REAL NOT NULL DEFAULT 0,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT
      )
    ''');
  }

  Future<List<Product>> getProducts({String? category}) async {
    final d = await db;
    final maps = await d.query(
      'products',
      where: category == null ? null : 'category = ?',
      whereArgs: category == null ? null : [category],
      orderBy: 'name ASC',
    );
    return maps.map(Product.fromMap).toList();
  }

  Future<int> insertProduct(Product p) async {
    final d = await db;
    return d.insert('products', p.toMap());
  }

  Future<int> updateProduct(Product p) async {
    final d = await db;
    return d.update('products', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deleteProduct(int id) async {
    final d = await db;
    return d.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Txn>> getTransactions({DateTime? from, DateTime? to, String? category}) async {
    final d = await db;
    final w = <String>[];
    final a = <dynamic>[];
    if (from != null && to != null) {
      w.add('date BETWEEN ? AND ?');
      a.add(from.toIso8601String());
      a.add(to.toIso8601String());
    }
    if (category != null && category != 'Semua') {
      w.add('category = ?');
      a.add(category);
    }
    final maps = await d.query(
      'transactions',
      where: w.isEmpty ? null : w.join(' AND '),
      whereArgs: a.isEmpty ? null : a,
      orderBy: 'date DESC',
    );
    return maps.map(Txn.fromMap).toList();
  }

  Future<int> insertTxn(Txn t) async {
    final d = await db;
    return d.insert('transactions', t.toMap());
  }

  Future<int> deleteTxn(int id) async {
    final d = await db;
    return d.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Customer>> getCustomers() async {
    final d = await db;
    final maps = await d.query('customers', orderBy: 'name ASC');
    return maps.map(Customer.fromMap).toList();
  }

  Future<int> insertCustomer(Customer c) async {
    final d = await db;
    return d.insert('customers', c.toMap());
  }
}
