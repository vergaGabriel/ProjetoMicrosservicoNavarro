import 'package:flutter/material.dart';

class AdminOrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> pedido;

  const AdminOrderDetailPage({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Detalhes do Pedido'),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Text('Cliente: ${pedido['cliente']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 12),
            Text('Total: R\$ ${pedido['total']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 12),
            Text('Status: ${pedido['status']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 24),
            const Text('Itens do pedido:', style: TextStyle(color: Colors.amberAccent, fontSize: 16)),
            const SizedBox(height: 12),
            const ListTile(
              title: Text('Produto Exemplo 1', style: TextStyle(color: Colors.white)),
              subtitle: Text('Quantidade: 1  |  R\$ 99.95', style: TextStyle(color: Colors.white70)),
            ),
            const ListTile(
              title: Text('Produto Exemplo 2', style: TextStyle(color: Colors.white)),
              subtitle: Text('Quantidade: 1  |  R\$ 99.95', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
