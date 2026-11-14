const kCategories = [
  'Pulsa',
  'Kuota',
  'Voucher',
  'Token Listrik',
  'E-Wallet',
  'Kartu Perdana',
  'Aksesoris',
  'Bayar Listrik',
  'Bayar Air',
  'Transfer Bank',
];

double toNum(String? s) {
  final t = (s ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  return double.tryParse(t) ?? 0;
}

class Product {
  int? id;
  String category;
  String name;
  double basePrice;
  double price;
  bool active;

  Product({
    this.id,
    required this.category,
    required this.name,
    this.basePrice = 0,
    this.price = 0,
    this.active = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'name': name,
        'base_price': basePrice,
        'price': price,
        'active': active ? 1 : 0,
      };

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'],
        category: m['category'] ?? 'Pulsa',
        name: m['name'] ?? '',
        basePrice: (m['base_price'] ?? 0).toDouble(),
        price: (m['price'] ?? 0).toDouble(),
        active: (m['active'] ?? 1) == 1,
      );
}

class Txn {
  int? id;
  DateTime date;
  String category;
  String productName;
  String target;
  int qty;
  double basePrice;
  double price;
  String? note;

  Txn({
    this.id,
    required this.date,
    required this.category,
    required this.productName,
    required this.target,
    this.qty = 1,
    this.basePrice = 0,
    required this.price,
    this.note,
  });

  double get total => price * qty;
  double get profit => (price - basePrice) * qty;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'category': category,
        'product_name': productName,
        'target': target,
        'qty': qty,
        'base_price': basePrice,
        'price': price,
        'note': note,
      };

  factory Txn.fromMap(Map<String, dynamic> m) => Txn(
        id: m['id'],
        date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
        category: m['category'] ?? 'Pulsa',
        productName: m['product_name'] ?? '',
        target: m['target'] ?? '',
        qty: m['qty'] ?? 1,
        basePrice: (m['base_price'] ?? 0).toDouble(),
        price: (m['price'] ?? 0).toDouble(),
        note: m['note'],
      );
}

class Customer {
  int? id;
  String name;
  String? phone;

  Customer({this.id, required this.name, this.phone});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'phone': phone};

  factory Customer.fromMap(Map<String, dynamic> m) =>
      Customer(id: m['id'], name: m['name'] ?? '', phone: m['phone']);
}
