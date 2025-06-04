import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/dashboard_option.dart';

class DashboardService {
  static List<DashboardOption> getOptions(BuildContext context) {
    final bool isAdmin = AuthService.isAdmin;

    if (isAdmin) {
      return [
        DashboardOption(
          label: 'Produtos',
          icon: Icons.inventory_2,
          route: '/admin_products',
        ),
        DashboardOption(
          label: 'Pedidos',
          icon: Icons.list_alt,
          route: '/orders',
        ),
        DashboardOption(
          label: 'Cadastros',
          icon: Icons.person_add_alt_1,
          route: '/register',
        ),
      ];
    } else {
      return [
        DashboardOption(
          label: 'Minhas Compras',
          icon: Icons.shopping_bag,
          route: '/orders',
        ),
        DashboardOption(
          label: 'Meus Dados',
          icon: Icons.person,
          route: '/profile',
        ),
      ];
    }
  }
}
