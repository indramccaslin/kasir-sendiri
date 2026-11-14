import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';
import '../format.dart';
import '../categories.dart';
import 'products_screen.dart';

const _indigo = Color(0xFF4F46E5);

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _cat = 'Pulsa';
  int? _productId;
  int _qty = 1;
  final _targetC = TextEditingController();
  final _baseC = TextEditingController();
  final _priceC = TextEditingController();
  final _noteC = TextEditingController();

  @override
  void dispose() {
    _targetC.dispose();
    _baseC.dispose();
    _priceC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  double get _base => toNum(_baseC.text);
  double get _price => toNum(_priceC.text);
  double get _profit => (_price - _base) * _qty;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final prods = s.byCategory(_cat);
    final validId = prods.any((p) => p.id == _productId) ? _productId : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Transaksi Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: kCategories.map((c) {
                  final sel = _cat == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    onSelected: (_) => setState(() {
                      _cat = c;
                      _productId = null;
                      _baseC.clear();
                      _priceC.clear();
                    }),
                    selectedColor: const Color(0xFFEEF2FF),
                    labelStyle: TextStyle(
                      color: sel ? _indigo : Colors.grey.shade700,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Produk / nominal',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: validId,
                          hint: Text(prods.isEmpty ? 'Belum ada produk' : 'Pilih produk'),
                          items: prods
                              .map((p) => DropdownMenuItem<int>(
                                    value: p.id!,
                                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: prods.isEmpty
                              ? null
                              : (v) {
                                  final p = prods.firstWhere((e) => e.id == v);
                                  setState(() {
                                    _productId = v;
                                    _baseC.text = p.basePrice.toStringAsFixed(0);
                                    _priceC.text = p.price.toStringAsFixed(0);
                                  });
                                },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: _indigo, foregroundColor: Colors.white),
                    tooltip: 'Tambah produk',
                    onPressed: _quickAddProduct,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (prods.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Tambah produk dulu di menu Produk.',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade800)),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _targetC,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: targetLabel(_cat),
                  hintText: targetHint(_cat),
                  prefixIcon: const Icon(Icons.numbers),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _numField('Modal', _baseC, Icons.payments_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _numField('Harga jual', _priceC, Icons.sell_outlined)),
              ]),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  _roundBtn(Icons.remove, _qty > 1 ? () => setState(() => _qty--) : null),
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: Text('$_qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _roundBtn(Icons.add, () => setState(() => _qty++)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Untung'),
                    Text(
                      rupiah.format(_profit),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _profit < 0 ? Colors.red : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteC,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _save(s, prods),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('SIMPAN TRANSAKSI', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Transaksi terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        if (s.transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey))),
          ),
        ...s.transactions.take(10).map((t) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Icon(categoryIcon(t.category), color: _indigo, size: 20),
                ),
                title: Text('${t.productName} x${t.qty}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${t.category} • ${t.target} • ${dateTimeFmt.format(t.date)}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(rupiah.format(t.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('+${rupiah.format(t.profit)}',
                          style: const TextStyle(fontSize: 11, color: Colors.green)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => s.deleteTxn(t.id!),
                  ),
                ]),
              ),
            )),
      ],
    );
  }

  Widget _numField(String label, TextEditingController c, IconData icon) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback? onTap) {
    return Material(
      color: onTap == null ? Colors.grey.shade200 : const Color(0xFFEEF2FF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: onTap == null ? Colors.grey : _indigo),
        ),
      ),
    );
  }

  Future<void> _quickAddProduct() async {
    await showDialog<void>(
      context: context,
      builder: (_) => ProductDialog(initialCategory: _cat),
    );
  }

  Future<void> _save(AppState s, List<Product> prods) async {
    final messenger = ScaffoldMessenger.of(context);
    if (_productId == null || !prods.any((p) => p.id == _productId)) {
      messenger.showSnackBar(const SnackBar(content: Text('Pilih produk dulu')));
      return;
    }
    if (targetRequired(_cat) && _targetC.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text('${targetLabel(_cat)} wajib diisi')));
      return;
    }
    if (_price <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Harga jual harus lebih dari 0')));
      return;
    }
    final p = prods.firstWhere((e) => e.id == _productId);
    await s.addTxn(Txn(
      date: DateTime.now(),
      category: _cat,
      productName: p.name,
      target: _targetC.text.trim().isEmpty ? '-' : _targetC.text.trim(),
      qty: _qty,
      basePrice: _base,
      price: _price,
      note: _noteC.text.trim().isEmpty ? null : _noteC.text.trim(),
    ));
    _targetC.clear();
    _noteC.clear();
    setState(() {
      _qty = 1;
      _productId = null;
      _baseC.clear();
      _priceC.clear();
    });
    messenger.showSnackBar(const SnackBar(content: Text('Transaksi disimpan')));
  }
}
