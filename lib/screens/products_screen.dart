import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';
import 'package:intl/intl.dart';

final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _nameC = TextEditingController();
  final _priceC = TextEditingController();
  final _stockC = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Produk & Jasa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(flex: 2, child: _input('Nama produk', _nameC)),
                const SizedBox(width: 8),
                Expanded(child: _input('Harga', _priceC, keyboard: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: _input('Stok', _stockC, keyboard: TextInputType.number)),
                const SizedBox(width: 8),
                FilledButton(onPressed: _add, child: const Text('Simpan')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: s.products.length,
              itemBuilder: (_, i) {
                final p = s.products[i];
                return ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.indigo),
                  title: Text(p.name),
                  subtitle: Text('${p.category ?? '-'}  •  Stok ${p.stock}'),
                  trailing: Text(currency.format(p.price)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController c, {TextInputType? keyboard}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Future<void> _add() async {
    final s = context.read<AppState>();
    await s.addProduct(Product(
      name: _nameC.text,
      price: double.tryParse(_priceC.text) ?? 0,
      retailPrice: double.tryParse(_priceC.text) ?? 0,
      stock: int.tryParse(_stockC.text) ?? 0,
    ));
    _nameC.clear(); _priceC.clear(); _stockC.text = '0';
  }

  @override
  void dispose() {
    _nameC.dispose(); _priceC.dispose(); _stockC.dispose();
    super.dispose();
  }
}
