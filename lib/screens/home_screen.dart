import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';
import 'package:intl/intl.dart';

final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double today = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = context.read<AppState>();
    today = await s.todayTotal();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir Sendiri'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _statCard('Penjualan Hari Ini', currency.format(today), Colors.indigo),
            const SizedBox(height: 12),
            _statCard('Produk', '${s.products.length}', Colors.green),
            const SizedBox(height: 12),
            _statCard('Pelanggan', '${s.customers.length}', Colors.orange),
            const SizedBox(height: 20),
            const Text('Aksi Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _actionBtn('Transaksi', Icons.point_of_sale, () => Navigator.pushNamed(context, '/sales')),
                _actionBtn('Produk', Icons.shopping_bag, () => Navigator.pushNamed(context, '/products')),
                _actionBtn('Pelanggan', Icons.people, () => Navigator.pushNamed(context, '/customers')),
                _actionBtn('Laporan', Icons.bar_chart, () => Navigator.pushNamed(context, '/reports')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Produk Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...s.products.take(6).map((p) => ListTile(
              leading: const Icon(Icons.inventory, color: Colors.grey),
              title: Text(p.name),
              subtitle: Text('Stok: ${p.stock}  •  ${currency.format(p.price)}'),
              trailing: TextButton(onPressed: () {}, child: const Text('Pilih')),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/sales'),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Transaksi Baru'),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _actionBtn(String title, IconData icon, VoidCallback onTap) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
    );
  }
}
