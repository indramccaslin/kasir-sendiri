import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';

final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final dateFmt = DateFormat('dd MMM yyyy', 'id_ID');

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _day = DateTime.now();
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await context.read<AppState>().todayTotal();
    setState(() => _total = t);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _day, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) {
      setState(() => _day = picked);
      final s = context.read<AppState>();
      final t = await s.todayTotal(); // today only for now; keep simple
      setState(() => _total = t);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final paid = s.sales.where((x) => x.status == 'paid').toList();
    final count = paid.length;
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Tanggal: ${dateFmt.format(_day)}', style: const TextStyle(fontSize: 16)),
                const Spacer(),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: 'Muat ulang'),
                const SizedBox(width: 4),
                ElevatedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today), label: const Text('Pilih')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _stat('Total Transaksi', '$count', Colors.blue),
                _stat('Total Penjualan', currency.format(_total), Colors.green),
                _stat('Produk Terjual', '${s.sales.fold(0, (sum, x) => sum + x.items.length)}', Colors.indigo),
                _stat('Rata-Rata', count > 0 ? currency.format(_total / count) : currency.format(0), Colors.orange),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: paid.length,
              itemBuilder: (_, i) {
                final x = paid[i];
                return ListTile(
                  leading: const Icon(Icons.receipt, color: Colors.teal),
                  title: Text('Transaksi #${x.id}'),
                  subtitle: Text(dateFmt.format(x.date)),
                  trailing: Text(currency.format(x.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
    );
  }

  Widget _stat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
