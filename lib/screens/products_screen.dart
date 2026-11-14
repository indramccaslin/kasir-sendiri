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
  final _baseC = TextEditingController();
  final _priceC = TextEditingController();
  final _stockC = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              TextField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nama produk / jasa', prefixIcon: Icon(Icons.label_outline), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numField('Harga dasar (modal)', _baseC)),
                  const SizedBox(width: 10),
                  Expanded(child: _numField('Harga jual', _priceC)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numField('Stok', _stockC)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _add,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Simpan'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: s.products.isEmpty
              ? const Center(child: Text('Belum ada produk', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: s.products.length,
                  itemBuilder: (_, i) {
                    final p = s.products[i];
                    final margin = p.price - p.basePrice;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                        ),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Modal ${currency.format(p.basePrice)}  •  Stok ${p.stock}'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(currency.format(p.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              'Laba ${currency.format(margin)}',
                              style: TextStyle(fontSize: 11, color: margin >= 0 ? Colors.green : Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _numField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Future<void> _add() async {
    if (_nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama produk wajib diisi')));
      return;
    }
    final s = context.read<AppState>();
    await s.addProduct(Product(
      name: _nameC.text.trim(),
      basePrice: double.tryParse(_baseC.text) ?? 0,
      price: double.tryParse(_priceC.text) ?? 0,
      retailPrice: double.tryParse(_priceC.text) ?? 0,
      stock: int.tryParse(_stockC.text) ?? 0,
    ));
    _nameC.clear();
    _baseC.clear();
    _priceC.clear();
    _stockC.text = '0';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk disimpan')));
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _baseC.dispose();
    _priceC.dispose();
    _stockC.dispose();
    super.dispose();
  }
}
