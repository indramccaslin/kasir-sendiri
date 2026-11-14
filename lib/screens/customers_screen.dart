import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';

const _indigo = Color(0xFF4F46E5);

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

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
                decoration: const InputDecoration(
                  labelText: 'Nama pelanggan',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor HP',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: _indigo),
                      onPressed: _add,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: s.customers.isEmpty
              ? const Center(child: Text('Belum ada pelanggan', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: s.customers.length,
                  itemBuilder: (_, i) {
                    final c = s.customers[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Text(
                            c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: _indigo, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(c.phone?.isNotEmpty == true ? c.phone! : '-'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _add() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_nameC.text.trim().isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Nama wajib diisi')));
      return;
    }
    await context.read<AppState>().addCustomer(Customer(
          name: _nameC.text.trim(),
          phone: _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        ));
    _nameC.clear();
    _phoneC.clear();
    messenger.showSnackBar(const SnackBar(content: Text('Pelanggan disimpan')));
  }
}
