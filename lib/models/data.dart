class Product {
  int? id;
  String name;
  String? category;
  double price;
  double retailPrice;
  int stock;
  String? barcode;

  Product({
    this.id,
    required this.name,
    this.category,
    required this.price,
    required this.retailPrice,
    this.stock = 0,
    this.barcode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'retail_price': retailPrice,
      'stock': stock,
      'barcode': barcode,
    };
  }

  factory Product.fromMap(Map<String, dynamic> m) {
    return Product(
      id: m['id'],
      name: m['name'] ?? '',
      category: m['category'],
      price: (m['price'] ?? 0).toDouble(),
      retailPrice: (m['retail_price'] ?? 0).toDouble(),
      stock: m['stock'] ?? 0,
      barcode: m['barcode'],
    );
  }
}

class Customer {
  int? id;
  String name;
  String? phone;
  String? address;

  Customer({this.id, required this.name, this.phone, this.address});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'address': address};
  }

  factory Customer.fromMap(Map<String, dynamic> m) {
    return Customer(
      id: m['id'],
      name: m['name'] ?? '',
      phone: m['phone'],
      address: m['address'],
    );
  }
}

class SaleItem {
  Product product;
  int qty;
  double price;

  SaleItem({required this.product, required this.qty, required this.price});

  double get subtotal => qty * price;

  Map<String, dynamic> toMap() {
    return {
      'product_id': product.id,
      'qty': qty,
      'price': price,
    };
  }
}

class Sale {
  int? id;
  DateTime date;
  int customerId;
  List<SaleItem> items;
  double subtotal;
  double tax;
  double shipping;
  double total;
  double cash;
  double change;
  String status;

  Sale({
    this.id,
    required this.date,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.cash,
    required this.change,
    this.status = 'paid',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'customer_id': customerId,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'cash': cash,
      'change': change,
      'status': status,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> m) {
    return Sale(
      id: m['id'],
      date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
      customerId: m['customer_id'] ?? 0,
      items: [],
      subtotal: (m['subtotal'] ?? 0).toDouble(),
      tax: (m['tax'] ?? 0).toDouble(),
      shipping: (m['shipping'] ?? 0).toDouble(),
      total: (m['total'] ?? 0).toDouble(),
      cash: (m['cash'] ?? 0).toDouble(),
      change: (m['change'] ?? 0).toDouble(),
      status: m['status'] ?? 'paid',
    );
  }
}
