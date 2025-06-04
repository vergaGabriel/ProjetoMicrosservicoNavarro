import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/pedido_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _futurePedidos;
  bool exibirTodos = false;

  bool get isAdmin => AuthService.isAdmin;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  void _carregarPedidos() {
    if (isAdmin) {
      _futurePedidos = PedidoService.buscarTodosPedidos();
    } else {
      final userId = AuthService.userIdLogado;
      _futurePedidos = PedidoService.buscarPedidosPorUsuario(userId!);
    }
  }

  Future<void> _recarregarPedidos() async {
    setState(() {
      _carregarPedidos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isAdmin ? 'Pedidos Recebidos' : 'Meus Pedidos'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _recarregarPedidos,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futurePedidos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Erro ao carregar pedidos',
                          style: TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum pedido encontrado.',
                          style: TextStyle(color: Colors.white)));
                }

                final pedidos = snapshot.data!;
                final pedidosParaExibir = exibirTodos
                    ? pedidos.reversed.toList()
                    : pedidos.reversed.take(10).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: pedidosParaExibir.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pedido = pedidosParaExibir[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/order_detail',
                                arguments:
                                    isAdmin ? pedido['id'] : pedido,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt_long,
                                      color: Color(0xFF8A4DFF)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pedido #${pedido['id']} - R\$ ${pedido['valorTotal'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Status: ${pedido['status']} | Pagamento: ${pedido['formaPagamento'] ?? '---'}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.white70),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (!exibirTodos && pedidos.length > 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              exibirTodos = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A4DFF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Exibir todos',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
