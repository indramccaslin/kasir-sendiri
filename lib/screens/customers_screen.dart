import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/data.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(flex: 2, child: _input('Nama', _nameC)),
                const SizedBox(width: 8),
                Expanded(child: _input('Telpon', _phoneC, keyboard: TextInputType.phone)),
                const SizedBox(width: 8),
                FilledButton(onPressed: _add, child: const Text('Simpan')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: s.customers.length,
              itemBuilder: (_, i) {
                final c = s.customers[i];
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.orange),
                  title: Text(c.name),
                  subtitle: Text(c.phone ?? '-'),
                  trailing: IconButton(icon: const Icon(Icons.check, color: Colors.orange), onPressed: () => s.setCustomer(c.id)),
                );
              },
            ),
          ),
        ],
    );
  }

  Widget _input(String label, TextEditingController c, {TextInputType? keyboard}) {
    return TextField(controller: c, keyboardType: keyboard, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
  }

  Future<void> _add() async {
    final s = context.read<AppState>();
    await s.addCustomer(Customer(name: _nameC.text, phone: _phoneC.text));
    _nameC.clear(); _phoneC.clear();
  }

  @override
  void dispose() {
    _nameC.dispose(); _phoneC.dispose();
    super.dispose();
  }
}
