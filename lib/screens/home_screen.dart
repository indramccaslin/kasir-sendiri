import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'package:intl/intl.dart';

final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpen});
  final ValueChanged<int> onOpen;

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
    final t = await s.todayTotal();
    if (mounted) setState(() => today = t);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Penjualan Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text(currency.format(today), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.now()), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _miniStat('Produk', '${s.products.length}', Icons.inventory_2_rounded, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _miniStat('Pelanggan', '${s.customers.length}', Icons.people_alt_rounded, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _miniStat('Transaksi', '${s.sales.length}', Icons.receipt_long_rounded, Colors.blue)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Aksi Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.9,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _quick('Transaksi', Icons.point_of_sale_rounded, Colors.indigo, () => widget.onOpen(2)),
              _quick('Produk', Icons.inventory_2_rounded, Colors.green, () => widget.onOpen(1)),
              _quick('Pelanggan', Icons.people_alt_rounded, Colors.orange, () => widget.onOpen(3)),
              _quick('Laporan', Icons.bar_chart_rounded, Colors.blue, () => widget.onOpen(4)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Produk Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          if (s.products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Belum ada produk. Tambahkan di menu Produk.', style: TextStyle(color: Colors.grey))),
            )
          else
            ...s.products.take(6).map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                    ),
                    title: Text(p.name),
                    subtitle: Text('Stok ${p.stock}  •  ${currency.format(p.price)}'),
                    trailing: Text(currency.format(p.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _quick(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
