import 'package:flutter/material.dart';


import 'screens/shared pages/login.dart';
import 'screens/shared pages/register.dart';
import 'screens/shared pages/order_detail.dart';
import 'screens/shared pages/products_list.dart'; 
import 'screens/shared pages/dashboard.dart';
import 'screens/shared pages/product_detail.dart';
import 'screens/shared pages/orders.dart';

import 'screens/user pages/cart_page.dart';
import 'screens/user pages/checkout_page.dart';

import 'screens/admin pages/admin_add_product.dart';



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
      theme: ThemeData.dark(),
      initialRoute: '/login',
      // home: kDebugMode ? const DevLoginPage() : const LoginPage(),
      // ou apenas:
      // home: const DevLoginPage(),

      // rotas definidas como antes
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/dashboard': (_) => const DashboardPage(), // NOVA TELA UNIFICADA
        '/product_detail': (_) => const ProductDetail(),
        '/orders': (_) => const OrdersPage(),
        '/order_detail': (_) => const OrderDetailPage(),

        // Usuário
        '/products': (_) => const ProductsSharedPage(isAdmin: false),
        '/cart': (_) => const CartPage(),
        '/checkout': (_) => const CheckoutPage(),

        // Admin
        '/admin_add_product': (_) => const AddProductPage(),
        '/admin_products': (_) => const ProductsSharedPage(isAdmin: true),
        
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/order_detail') {
          final args = settings.arguments;

          if (args is int) {
            return MaterialPageRoute(
              builder: (_) => OrderDetailPage(pedidoId: args),
            );
          }

          if (args is Map<String, dynamic> && args['id'] != null) {
            return MaterialPageRoute(
              builder: (_) => OrderDetailPage(pedidoId: args['id']),
            );
          }

          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('❌ Argumento inválido para /order_detail')),
            ),
          );
        }

        if (settings.name == '/admin_register') {
          return MaterialPageRoute(
            builder: (_) => const RegisterPage(isAdminRegister: true),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('❌ Rota não encontrada')),
          ),
        );
      },
    );
  }
}
