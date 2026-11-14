import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';
import '../format.dart';
import '../categories.dart';
import '../receipt.dart';

const _indigo = Color(0xFF4F46E5);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _cat = 'Semua';
  int _period = 0;
  static const _periods = ['Hari ini', '7 Hari', '30 Hari', 'Semua'];

  List<Txn> _filtered(AppState s) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? from;
    if (_period == 0) from = today;
    if (_period == 1) from = today.subtract(const Duration(days: 6));
    if (_period == 2) from = today.subtract(const Duration(days: 29));
    return s.transactions.where((t) {
      if (_cat != 'Semua' && t.category != _cat) return false;
      if (from != null && t.date.isBefore(from)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = _filtered(s);
    final omzet = s.sumTotal(list);
    final modal = s.sumModal(list);
    final laba = s.sumProfit(list);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Periode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: List.generate(_periods.length, (i) {
            final sel = _period == i;
            return ChoiceChip(
              label: Text(_periods[i]),
              selected: sel,
              onSelected: (_) => setState(() => _period = i),
              selectedColor: const Color(0xFFEEF2FF),
              labelStyle: TextStyle(
                color: sel ? _indigo : Colors.grey.shade700,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: ['Semua', ...kCategories].map((c) {
            final sel = _cat == c;
            return ChoiceChip(
              label: Text(c),
              selected: sel,
              onSelected: (_) => setState(() => _cat = c),
              selectedColor: const Color(0xFFEEF2FF),
              labelStyle: TextStyle(
                color: sel ? _indigo : Colors.grey.shade700,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
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
              const Text('Total Omzet', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(rupiah.format(omzet),
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Row(children: [
                _stat('Modal', rupiah.format(modal)),
                const SizedBox(width: 20),
                _stat('Laba', rupiah.format(laba)),
                const SizedBox(width: 20),
                _stat('Transaksi', '${list.length}'),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Per kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        ...kCategories.map((c) {
          final l = list.where((t) => t.category == c);
          if (l.isEmpty) return const SizedBox.shrink();
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(rupiah.format(s.sumTotal(l)), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Text('+${rupiah.format(s.sumProfit(l))}',
                      style: const TextStyle(fontSize: 11, color: Colors.green)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        const Text('Detail transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Tidak ada data', style: TextStyle(color: Colors.grey))),
          ),
        ...list.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => showReceipt(context, t),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Icon(categoryIcon(t.category), color: _indigo, size: 20),
                ),
                title: Text('${t.productName} x${t.qty}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${t.category} • ${t.target} • ${dateTimeFmt.format(t.date)}'),
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
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      );
}
