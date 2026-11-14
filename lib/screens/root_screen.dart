import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'sales_screen.dart';
import 'customers_screen.dart';
import 'reports_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _titles = ['Dashboard', 'Transaksi', 'Produk', 'Pelanggan', 'Laporan'];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOpen: _select),
      const SalesScreen(),
      const ProductsScreen(),
      const CustomersScreen(),
      const ReportsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index], style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      drawer: _drawer(),
      body: IndexedStack(index: _index, children: pages),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 170,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.account_balance_wallet, color: Color(0xFF4F46E5), size: 26),
                ),
                SizedBox(height: 12),
                Text('PULSA PPOB VOUCHER',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Catatan transaksi harian', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _item('Dashboard', Icons.dashboard_rounded, 0),
          _item('Transaksi', Icons.point_of_sale_rounded, 1),
          _item('Produk', Icons.inventory_2_rounded, 2),
          _item('Pelanggan', Icons.people_alt_rounded, 3),
          _item('Laporan', Icons.bar_chart_rounded, 4),
        ],
      ),
    );
  }

  Widget _item(String title, IconData icon, int i) {
    final selected = _index == i;
    return ListTile(
      leading: Icon(icon, color: selected ? const Color(0xFF4F46E5) : Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? const Color(0xFF4F46E5) : Colors.black87,
        ),
      ),
      selected: selected,
      selectedTileColor: const Color(0xFFEEF2FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.pop(context);
        _select(i);
      },
    );
  }
}
