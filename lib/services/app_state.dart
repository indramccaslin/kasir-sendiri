import 'package:flutter/material.dart';
import '../models/data.dart';
import '../services/database_helper.dart';

class AppState extends ChangeNotifier {
  final db = DatabaseHelper();
  List<Product> _products = [];
  List<Customer> _customers = [];
  List<Sale> _sales = [];
  List<SaleItem> _cart = [];
  int? _selectedCustomerId;
  bool _loading = true;

  List<Product> get products => _products;
  List<Customer> get customers => _customers;
  List<Sale> get sales => _sales;
  List<SaleItem> get cart => _cart;
  int? get selectedCustomerId => _selectedCustomerId;
  bool get loading => _loading;

  double get cartSubtotal => _cart.fold(0, (sum, it) => sum + it.subtotal);
  double get grandTotal => cartSubtotal;

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    _products = await db.getProducts();
    _customers = await db.getCustomers();
    _sales = await db.getSales();
    _loading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    await db.insertProduct(p);
    _products = await db.getProducts();
    notifyListeners();
  }

  Future<void> addCustomer(Customer c) async {
    await db.insertCustomer(c);
    _customers = await db.getCustomers();
    notifyListeners();
  }

  void setCustomer(int? id) {
    _selectedCustomerId = id;
    notifyListeners();
  }

  void addToCart(Product p, {int qty = 1}) {
    final idx = _cart.indexWhere((it) => it.product.id == p.id);
    if (idx >= 0) {
      _cart[idx] = SaleItem(product: _cart[idx].product, qty: _cart[idx].qty + qty, price: p.price);
    } else {
      _cart.add(SaleItem(product: p, qty: qty, price: p.price));
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cart.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _selectedCustomerId = null;
    notifyListeners();
  }

  Future<void> checkout({required double cash}) async {
    final sale = Sale(
      date: DateTime.now(),
      customerId: _selectedCustomerId ?? 0,
      items: List.from(_cart),
      subtotal: cartSubtotal,
      tax: 0,
      shipping: 0,
      total: grandTotal,
      cash: cash,
      change: cash - grandTotal,
    );
    await db.insertSale(sale);
    _sales = await db.getSales();
    clearCart();
    notifyListeners();
  }

  Future<double> todayTotal() async => db.dailyTotal(DateTime.now());

  Future<void> refresh() async => init();
}
