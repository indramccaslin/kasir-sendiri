import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';
import '../format.dart';
import '../categories.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onOpen;
  const HomeScreen({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final today = s.onDay(DateTime.now());
    final omzet = s.sumTotal(today);
    final laba = s.sumProfit(today);
    final modal = s.sumModal(today);

    return RefreshIndicator(
      onRefresh: s.refresh,
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
                const Text('Omzet hari ini', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(rupiah.format(omzet),
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(children: [
                  _mini('Laba', rupiah.format(laba), Icons.trending_up),
                  const SizedBox(width: 16),
                  _mini('Modal', rupiah.format(modal), Icons.payments_outlined),
                  const SizedBox(width: 16),
                  _mini('Transaksi', '${today.length}', Icons.receipt_long),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Per kategori (hari ini)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.8,
            children: kCategories.map((c) {
              final v = s.sumTotal(today.where((t) => t.category == c));
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Icon(categoryIcon(c), color: const Color(0xFF4F46E5), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(rupiah.format(v),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _action('Transaksi Baru', Icons.add_circle, () => onOpen(1))),
            const SizedBox(width: 8),
            Expanded(child: _action('Kelola Produk', Icons.inventory_2, () => onOpen(2))),
            const SizedBox(width: 8),
            Expanded(child: _action('Laporan', Icons.bar_chart, () => onOpen(4))),
          ]),
          const SizedBox(height: 20),
          const Text('Transaksi terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          if (s.transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey))),
            ),
          ...s.transactions.take(6).map((t) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: Icon(categoryIcon(t.category), color: const Color(0xFF4F46E5), size: 20),
                  ),
                  title: Text(t.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${t.target} • ${dateFmt.format(t.date)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(rupiah.format(t.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('+${rupiah.format(t.profit)}',
                          style: const TextStyle(fontSize: 11, color: Colors.green)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _mini(String label, String value, IconData ic) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(ic, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      );

  Widget _action(String label, IconData ic, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(children: [
            Icon(ic, color: const Color(0xFF4F46E5)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}
