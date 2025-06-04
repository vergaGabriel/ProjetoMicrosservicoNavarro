import 'package:flutter/material.dart';
import '../../services/pedido_service.dart';
import '../../services/produto_service.dart';

class OrderDetailPage extends StatefulWidget {
  final int? pedidoId;

  const OrderDetailPage({super.key, this.pedidoId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Map<String, dynamic>? pedido;
  bool carregando = true;

@override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!carregando || pedido != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    int? id;
    if (widget.pedidoId != null) {
      id = widget.pedidoId;
    } else if (args is Map<String, dynamic> && args['id'] != null) {
      id = args['id'] as int;
    } else if (args is int) {
      id = args;
    }

    if (id != null) {
      _carregarPedidoPorId(id);
    } else {
      Navigator.pop(context);
    }
  }
  Future<void> _carregarPedidoPorId(int id) async {
    final resultado = await PedidoService.buscarPedidoPorId(id);
    if (resultado != null) {
      pedido = resultado;
      await _carregarProdutosNosItens();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Pedido não encontrado')),
        );
        Navigator.pop(context);
      }
    }
    if (mounted) {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> _carregarProdutosNosItens() async {
    final itens = pedido?['itens'] as List? ?? [];

    for (var item in itens) {
      final produtoId = item['produtoId'];
      final produto = await ProdutoService.buscarProdutoPorId(produtoId);
      if (produto != null) {
        item['produto'] = produto; // Adiciona manualmente ao item
      }
    }

    if (mounted) {
      setState(() {}); // Atualiza para exibir os dados agora completos
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pedido'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: carregando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8A4DFF)),
              )
            : pedido == null
                ? const Center(
                    child: Text('Pedido não encontrado', style: TextStyle(color: Colors.white)))
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pedido #${pedido!['id']}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${pedido!['status']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pagamento: ${pedido!['formaPagamento'] ?? '---'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Itens:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),

                          // ✅ Tratamento seguro dos itens
                          Expanded(
                            child: Builder(
                              builder: (_) {
                                final itens = (pedido?['itens'] as List?) ?? [];

                                if (itens.isEmpty) {
                                  return const Text(
                                    'Nenhum item encontrado.',
                                    style: TextStyle(color: Colors.white70),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: itens.length,
                                  itemBuilder: (_, index) {
                                    final item = itens[index];
                                    final produto = item['produto'];

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              produto?['imagem'] ?? '',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: Colors.grey[800],
                                                width: 60,
                                                height: 60,
                                                child: const Icon(Icons.image_not_supported,
                                                    color: Colors.white54),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  produto?['nome'] ?? 'Produto',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${item['quantidade']}x - R\$ ${item['precoUnitario'].toStringAsFixed(2)}',
                                                  style: const TextStyle(color: Colors.white70),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Total: R\$ ${pedido!['valorTotal'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

}
