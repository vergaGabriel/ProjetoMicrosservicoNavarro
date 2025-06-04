import 'package:flutter/material.dart';
import '../../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<void> finalizarPedido() async {
    if (CartService.listarItens().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Carrinho está vazio.')),
      );
      return;
    }

    Navigator.pushNamed(context, '/checkout');

  }

  void _atualizarQuantidade(int produtoId, int novaQuantidade) async {
    setState(() {
      if (novaQuantidade <= 0) {
        CartService.removerItem(produtoId);
      } else {
        final item = CartService.listarItens().firstWhere((i) => i['id'] == produtoId);
        CartService.removerItem(produtoId);
        CartService.adicionarItem(item, novaQuantidade);
      }
    });
  }

  void _removerItem(int produtoId) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Remover item', style: TextStyle(color: Colors.white)),
        content: const Text('Deseja remover este item do carrinho?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              setState(() {
                CartService.removerItem(produtoId);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itensCarrinho = CartService.listarItens();
    final total = CartService.calcularTotal();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Carrinho (${itensCarrinho.fold<int>(0, (sum, i) => sum + (i['quantidade'] as int? ?? 0))})'),
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
        child: itensCarrinho.isEmpty
            ? _buildCarrinhoVazio()
            : _buildCarrinhoCheio(itensCarrinho, total),
      ),
    );
  }

  Widget _buildCarrinhoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          const Text('Seu carrinho está vazio', style: TextStyle(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Adicione produtos para continuar', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A4DFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ver Produtos', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrinhoCheio(List<Map<String, dynamic>> itens, double total) {
    return Column(
      children: [
        const SizedBox(height: kToolbarHeight + 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itens.length,
            itemBuilder: (context, index) {
              final item = itens[index];
              return Card(
                color: Colors.black.withOpacity(0.7),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[800],
                        ),
                        child: item['imagem'] != null && item['imagem'].toString().isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['imagem'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.white54),
                                ),
                              )
                            : const Icon(Icons.image_not_supported, color: Colors.white54),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nome'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${item['preco_Unidade'].toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFF8A4DFF), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _atualizarQuantidade(item['id'], item['quantidade'] - 1),
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8A4DFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${item['quantidade']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                onPressed: () => _atualizarQuantidade(item['id'], item['quantidade'] + 1),
                                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _removerItem(item['id']),
                            child: const Text('Remover', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('R\$ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, color: Color(0xFF8A4DFF), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: finalizarPedido,
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    label: const Text('Finalizar Compra', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4DFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
