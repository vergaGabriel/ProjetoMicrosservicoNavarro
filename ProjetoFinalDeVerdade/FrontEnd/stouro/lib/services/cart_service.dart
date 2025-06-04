import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'pedido_service.dart';

class CartService {
  static final List<Map<String, dynamic>> _itens = [];

  /// Adiciona um item ao carrinho local e envia para o backend Redis
  static Future<void> adicionarItem(Map<String, dynamic> produto, int quantidade) async {
    final existente = _itens.indexWhere((item) => item['id'] == produto['id']);
    if (existente != -1) {
      _itens[existente]['quantidade'] += quantidade;
    } else {
      _itens.add({...produto, 'quantidade': quantidade});
    }

    final userId = AuthService.userIdLogado;
    if (userId == null) return;

    // Verifica se já existe pedido com status 'cart'
    final pedidoExistente = await PedidoService.buscarUltimoPedidoDoUsuario(userId);
    final pedidoId = pedidoExistente != null && pedidoExistente['status'] == 'cart'
        ? pedidoExistente['id']
        : null;

    final body = jsonEncode({
      "usuarioId": userId,
      "itens": _itens.map((item) => {
        "produtoId": item['id'],
        "quantidade": item['quantidade'],
        "precoUnitario": item['preco_Unidade']
      }).toList(),
      if (pedidoId != null) "pedidoId": pedidoId // passa o pedido existente
    });

    try {
      await http.post(
        Uri.parse("http://10.0.2.2:5003/api/pedidos/iniciar"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    } catch (e) {
      print("❌ Erro ao enviar carrinho para API de pedidos: $e");
    }
  }

  /// Remove item do carrinho local
  static void removerItem(int produtoId) {
    _itens.removeWhere((item) => item['id'] == produtoId);
  }

  /// Lista todos os itens do carrinho local
  static List<Map<String, dynamic>> listarItens() {
    return List.from(_itens);
  }

  /// Calcula o total da compra
  static double calcularTotal() {
    return _itens.fold(0.0, (soma, item) => soma + (item['preco_Unidade'] * item['quantidade']));
  }

  /// Limpa carrinho local e remoto (Redis)
  static Future<void> limparCarrinho() async {
    final userId = AuthService.userIdLogado;
    _itens.clear();

    if (userId != null) {
      try {
        await http.delete(Uri.parse('http://10.0.2.2:5003/api/$userId/carrinho/limpar'));
      } catch (e) {
        print('Erro ao limpar carrinho do Redis: $e');
      }
    }
  }
  
}
