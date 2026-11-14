import 'package:flutter/material.dart';
import '../models/data.dart';
import 'database_helper.dart';

class AppState extends ChangeNotifier {
  final db = DatabaseHelper();
  List<Product> _products = [];
  List<Txn> _txns = [];
  List<Customer> _customers = [];
  bool _loading = true;

  List<Product> get products => _products;
  List<Txn> get transactions => _txns;
  List<Customer> get customers => _customers;
  bool get loading => _loading;

  List<Product> byCategory(String c) => _products.where((p) => p.category == c).toList();

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    _products = await db.getProducts();
    _txns = await db.getTransactions();
    _customers = await db.getCustomers();
    _loading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    await db.insertProduct(p);
    await _reloadProducts();
  }

  Future<void> updateProduct(Product p) async {
    await db.updateProduct(p);
    await _reloadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await db.deleteProduct(id);
    await _reloadProducts();
  }

  Future<void> _reloadProducts() async {
    _products = await db.getProducts();
    notifyListeners();
  }

  Future<void> addCustomer(Customer c) async {
    await db.insertCustomer(c);
    _customers = await db.getCustomers();
    notifyListeners();
  }

  Future<void> addTxn(Txn t) async {
    await db.insertTxn(t);
    _txns = await db.getTransactions();
    notifyListeners();
  }

  Future<void> deleteTxn(int id) async {
    await db.deleteTxn(id);
    _txns = await db.getTransactions();
    notifyListeners();
  }

  Future<void> refresh() => init();

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Txn> onDay(DateTime d) => _txns.where((t) => sameDay(t.date, d)).toList();

  double sumTotal(Iterable<Txn> l) => l.fold(0.0, (a, t) => a + t.total);
  double sumModal(Iterable<Txn> l) => l.fold(0.0, (a, t) => a + t.basePrice * t.qty);
  double sumProfit(Iterable<Txn> l) => l.fold(0.0, (a, t) => a + t.profit);
}
