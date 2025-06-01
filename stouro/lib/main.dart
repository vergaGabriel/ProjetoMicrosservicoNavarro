import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/product_list_page.dart';
import 'screens/product_detail_page.dart';
import 'screens/cart_page.dart';
import 'screens/checkout_page.dart';
import 'screens/profile_page.dart';
import 'screens/admin_page.dart';
import 'screens/admin_add_product.dart';
import 'screens/admin_orders.dart';
import 'screens/adress_page.dart';

void main() {
  runApp(const StouroApp());
}

class StouroApp extends StatelessWidget {
  const StouroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stouro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.amberAccent,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/products': (_) => const ProductListPage(),
        '/product_detail': (_) => const ProductDetailPage(),
        '/cart': (_) => const CartPage(),
        '/checkout': (_) => const CheckoutPage(),
        '/profile': (_) => const ProfilePage(),
        '/admin': (_) => const AdminPage(),
        '/admin_add_product': (_) => const AddProductPage(),
        '/admin_orders': (_) => const AdminOrdersPage(),
        '/enderecos': (_) => const AddressManagementPage(), // ✅ nova rota adicionada aqui
      },
    );
  }
}
