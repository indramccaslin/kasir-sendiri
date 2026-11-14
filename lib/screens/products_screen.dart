import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';
import '../format.dart';

const _indigo = Color(0xFF4F46E5);

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _cat = 'Pulsa';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.byCategory(_cat);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: kCategories.map((c) {
                      final sel = _cat == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: sel,
                          onSelected: (_) => setState(() => _cat = c),
                          selectedColor: const Color(0xFFEEF2FF),
                          labelStyle: TextStyle(
                            color: sel ? _indigo : Colors.grey.shade700,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _indigo),
                onPressed: _add,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text('Belum ada produk $_cat',
                      style: const TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final p = list[i];
                    final margin = p.price - p.basePrice;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        onTap: () => _edit(p),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: _indigo, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            'Modal ${rupiah.format(p.basePrice)}  •  Jual ${rupiah.format(p.price)}'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(rupiah.format(p.price),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              'Laba ${rupiah.format(margin)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: margin >= 0 ? Colors.green : Colors.red,
                              ),
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

  void _add() {
    showDialog<void>(
      context: context,
      builder: (_) => _ProductDialog(initialCategory: _cat),
    );
  }

  void _edit(Product p) {
    showDialog<void>(
      context: context,
      builder: (_) => _ProductDialog(product: p),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Product? product;
  final String initialCategory;
  const _ProductDialog({this.product, this.initialCategory = 'Pulsa'});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late String _cat = widget.product?.category ?? widget.initialCategory;
  late final _nameC = TextEditingController(text: widget.product?.name ?? '');
  late final _baseC = TextEditingController(
      text: widget.product == null ? '' : widget.product!.basePrice.toStringAsFixed(0));
  late final _priceC = TextEditingController(
      text: widget.product == null ? '' : widget.product!.price.toStringAsFixed(0));

  @override
  void dispose() {
    _nameC.dispose();
    _baseC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameC.text.trim().isEmpty) return;
    final s = context.read<AppState>();
    if (widget.product == null) {
      await s.addProduct(Product(
        category: _cat,
        name: _nameC.text.trim(),
        basePrice: toNum(_baseC.text),
        price: toNum(_priceC.text),
      ));
    } else {
      final p = widget.product!
        ..category = _cat
        ..name = _nameC.text.trim()
        ..basePrice = toNum(_baseC.text)
        ..price = toNum(_priceC.text);
      await s.updateProduct(p);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('Hapus "${widget.product!.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await context.read<AppState>().deleteProduct(widget.product!.id!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _cat,
                  items: kCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _cat = v!),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameC,
              decoration: const InputDecoration(
                labelText: 'Nama produk / nominal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _baseC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Modal', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _priceC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga jual', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        if (isEdit)
          TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}
