import 'package:flutter/material.dart';
import 'admin_order_detail.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidos = [
      {'cliente': 'Pedro', 'total': 199.90, 'status': 'Entregue'},
      {'cliente': 'Isa', 'total': 89.50, 'status': 'Em andamento'},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pedidos Recebidos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: pedidos.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white24),
          itemBuilder: (context, index) {
            final pedido = pedidos[index];
            return ListTile(
              title: Text(
                'Cliente: ${pedido['cliente']}',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Total: R\$ ${pedido['total']} | Status: ${pedido['status']}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminOrderDetailPage(pedido: pedido),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
