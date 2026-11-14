import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';
import 'package:intl/intl.dart';

final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _cashC = TextEditingController();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final filtered = s.products.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: Row(
        children: [
          Expanded(flex: 2, child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Cari produk', prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    final avail = p.stock > 0 ? Colors.green : Colors.red;
                    return ListTile(
                      leading: CircleAvatar(child: Text(p.name.isNotEmpty ? p.name[0] : '?'), backgroundColor: avail.withOpacity(0.15)),
                      title: Text(p.name, style: TextStyle(fontWeight: FontWeight.w600, color: p.stock > 0 ? null : Colors.red)),
                      subtitle: Text('${currency.format(p.price)}  •  Stok ${p.stock}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.indigo),
                        onPressed: p.stock > 0 ? () => context.read<AppState>().addToCart(p) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          )),
          const VerticalDivider(width: 1),
          Expanded(flex: 1, child: Column(
            children: [
              Expanded(child: _buildCart(s)),
              const Divider(),
              _buildCheckout(s),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildCart(AppState s) {
    if (s.cart.isEmpty) return const Center(child: Text('Keranjang kosong'));
    return ListView.builder(
      itemCount: s.cart.length,
      itemBuilder: (_, i) {
        final it = s.cart[i];
        return ListTile(
          leading: const Icon(Icons.shopping_bag_outlined),
          title: Text(it.product.name),
          subtitle: Text('${it.qty} x ${currency.format(it.price)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currency.format(it.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => s.removeFromCart(i))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckout(AppState s) {
    final total = s.grandTotal;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Total: ${currency.format(total)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _cashC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tunai', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Text('Kembali: ${currency.format((double.tryParse(_cashC.text) ?? 0) - total)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FilledButton(onPressed: total > 0 ? () => _checkout(s) : null, child: const Text('BAYAR & SELESAI')),
          const SizedBox(height: 6),
          OutlinedButton(onPressed: () => setState(() => s.clearCart()), child: const Text('Bersihkan')),
        ],
      ),
    );
  }

  Future<void> _checkout(AppState s) async {
    final cash = double.tryParse(_cashC.text) ?? 0;
    if (cash < s.grandTotal) return;
    await s.checkout(cash: cash);
    _cashC.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi selesai')));
      Navigator.pop(context);
    }
  }
}
