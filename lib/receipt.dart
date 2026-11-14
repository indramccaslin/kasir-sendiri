import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'models/data.dart';
import 'format.dart';

const kStoreName = 'GANESH STORE';

String receiptText(Txn t) {
  final b = StringBuffer();
  b.writeln('*$kStoreName*');
  b.writeln(dateTimeFmt.format(t.date));
  b.writeln('------------------------------');
  b.writeln('${t.category} - ${t.productName}');
  b.writeln('Tujuan: ${t.target}');
  b.writeln('${t.qty} x ${rupiah.format(t.price)} = ${rupiah.format(t.total)}');
  if (t.note != null && t.note!.isNotEmpty) b.writeln('Catatan: ${t.note}');
  b.writeln('------------------------------');
  b.writeln('TOTAL: ${rupiah.format(t.total)}');
  b.writeln('');
  b.writeln('Terima kasih');
  return b.toString();
}

Future<void> showReceipt(BuildContext context, Txn t) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ReceiptSheet(txn: t),
  );
}

class _ReceiptSheet extends StatelessWidget {
  final Txn txn;
  const _ReceiptSheet({required this.txn});

  @override
  Widget build(BuildContext context) {
    final text = receiptText(txn);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nota Digital',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                text,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nota disalin ke clipboard')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Salin'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                    onPressed: () => SharePlus.instance.share(ShareParams(text: text)),
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
