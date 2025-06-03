import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/cart_manager.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    CarrinhoManager.carregarItens();
  }

  Future<void> finalizarPedido() async {
    final pedidoId = CarrinhoManager.pedidoId;

    if (pedidoId == null || CarrinhoManager.getItens().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Carrinho está vazio.')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5207/api/pedidos/$pedidoId/finalizar'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        CarrinhoManager.limparCarrinho();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pedido finalizado com sucesso!')),
        );

        Navigator.pushNamed(context, '/checkout');
      } else {
        throw Exception(jsonDecode(response.body)['mensagem'] ?? 'Erro desconhecido');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erro ao finalizar pedido: $e')),
      );
    }
  }

  Future<void> _atualizarQuantidade(int produtoId, int novaQuantidade) async {
    if (novaQuantidade <= 0) {
      _removerItem(produtoId);
      return;
    }

    final sucesso = await CarrinhoManager.atualizarQuantidade(produtoId, novaQuantidade);
    if (sucesso) {
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Erro ao atualizar quantidade')),
      );
    }
  }

  Future<void> _removerItem(int produtoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Remover item', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deseja remover este item do carrinho?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final sucesso = await CarrinhoManager.removerItem(produtoId);
      if (sucesso) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Item removido do carrinho')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Erro ao remover item')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itensCarrinho = CarrinhoManager.getItens();
    final total = CarrinhoManager.calcularTotal();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Carrinho (${CarrinhoManager.getQuantidadeTotal()})'),
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
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white54),
                    const SizedBox(height: 16),
                    const Text(
                      'Seu carrinho está vazio',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicione produtos para continuar',
                      style: TextStyle(color: Colors.white70),
                    ),
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
              )
            : Column(
                children: [
                  const SizedBox(height: kToolbarHeight + 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: itensCarrinho.length,
                      itemBuilder: (context, index) {
                        final item = itensCarrinho[index];
                        return Card(
                          color: Colors.black.withOpacity(0.7),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Imagem do produto
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[800],
                                  ),
                                  child: item['imagemUrl'] != null && item['imagemUrl'].toString().isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            item['imagemUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.image_not_supported, color: Colors.white54);
                                            },
                                          ),
                                        )
                                      : const Icon(Icons.image_not_supported, color: Colors.white54),
                                ),
                                const SizedBox(width: 12),
                                
                                // Informações do produto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nome'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'R\$ ${item['preco_Unidade'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Color(0xFF8A4DFF),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Controles de quantidade
                                Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => _atualizarQuantidade(
                                            item['id'],
                                            item['quantidade'] - 1,
                                          ),
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                                          iconSize: 24,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8A4DFF),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${item['quantidade']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _atualizarQuantidade(
                                            item['id'],
                                            item['quantidade'] + 1,
                                          ),
                                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                                          iconSize: 24,
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () => _removerItem(item['id']),
                                      child: const Text(
                                        'Remover',
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
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
                  
                  // Resumo e botão de finalizar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'R\$ ${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF8A4DFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: finalizarPedido,
                              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                              label: const Text(
                                'Finalizar Compra',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
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
              ),
      ),
    );
  }
}