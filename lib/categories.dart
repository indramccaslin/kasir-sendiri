import 'package:flutter/material.dart';

IconData categoryIcon(String c) {
  switch (c) {
    case 'Pulsa':
      return Icons.smartphone;
    case 'Kuota':
      return Icons.wifi;
    case 'Voucher':
      return Icons.confirmation_number;
    case 'Token Listrik':
      return Icons.bolt;
    case 'E-Wallet':
      return Icons.account_balance_wallet;
    case 'Kartu Perdana':
      return Icons.sim_card;
    case 'Aksesoris':
      return Icons.headphones;
    case 'Bayar Listrik':
      return Icons.electrical_services;
    case 'Bayar Air':
      return Icons.water_drop;
    case 'Transfer Bank':
      return Icons.account_balance;
    default:
      return Icons.category;
  }
}

bool targetRequired(String c) => c != 'Aksesoris' && c != 'Kartu Perdana';

String targetLabel(String c) {
  switch (c) {
    case 'Bayar Listrik':
      return 'ID pelanggan / nomor meter';
    case 'Bayar Air':
      return 'ID / nomor pelanggan PDAM';
    case 'Transfer Bank':
      return 'No. rekening / nama penerima';
    case 'E-Wallet':
      return 'Nomor HP akun e-wallet';
    case 'Aksesoris':
    case 'Kartu Perdana':
      return 'Keterangan (opsional)';
    default:
      return 'Nomor HP tujuan';
  }
}

String targetHint(String c) {
  switch (c) {
    case 'Bayar Listrik':
      return 'mis. 51234567890';
    case 'Bayar Air':
      return 'mis. 12345678';
    case 'Transfer Bank':
      return 'mis. 1234567890 a.n. Budi';
    case 'Aksesoris':
      return 'mis. Casing / headset';
    case 'Kartu Perdana':
      return 'mis. Telkomsel 4G';
    default:
      return 'mis. 08123456789';
  }
}
