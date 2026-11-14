import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/reports_screen.dart';

void main() {
  runApp(const KasirApp());
}

class KasirApp extends StatelessWidget {
  const KasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'Kasir Sendiri',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF6366F1),
        ),
        home: const HomeScreen(),
        routes: {
          '/products': (context) => const ProductsScreen(),
          '/sales': (context) => const SalesScreen(),
          '/customers': (context) => const CustomersScreen(),
          '/reports': (context) => const ReportsScreen(),
        },
      ),
    );
  }
}
