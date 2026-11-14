import 'package:intl/intl.dart';

final rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final dateFmt = DateFormat('dd MMM yyyy', 'id_ID');
final dateTimeFmt = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
