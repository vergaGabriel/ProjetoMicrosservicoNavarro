import 'dart:convert';
import 'package:http/http.dart' as http;

class CarrinhoManager {
  static final List<Map<String, dynamic>> _itens = [];
  static const String baseUrl = 'http://10.0.2.2:5207';
  static int? _pedidoId;

  // Getters
  static int? get pedidoId => _pedidoId;
  static List<Map<String, dynamic>> getItens() => List.from(_itens);

  // Método para carregar itens do servidor
  static Future<void> carregarItens() async {
    if (_pedidoId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pedidos/$_pedidoId/itens'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> itens = jsonDecode(response.body);
        _itens.clear();
        _itens.addAll(itens.map((item) => Map<String, dynamic>.from(item)).toList());
      }
    } catch (e) {
      print('Erro ao carregar itens: $e');
    }
  }

  // Método para adicionar item ao carrinho
  static Future<void> adicionarItem(Map<String, dynamic> produto, int userId) async {
    try {
      // Se não há pedido ativo, cria um novo
      if (_pedidoId == null) {
        await _criarNovoPedido(userId);
      }

      // Adiciona o item à API
      final response = await http.post(
        Uri.parse('$baseUrl/api/pedidos/$_pedidoId/itens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'produtoId': produto['id'],
          'quantidade': 1,
        }),
      );

      if (response.statusCode == 201) {
        // Adiciona o item à memória local
        final itemExistente = _itens.firstWhere(
          (item) => item['id'] == produto['id'],
          orElse: () => {},
        );

        if (itemExistente.isNotEmpty) {
          itemExistente['quantidade'] = (itemExistente['quantidade'] ?? 0) + 1;
        } else {
          _itens.add({
            ...produto,
            'quantidade': 1,
          });
        }
      }
    } catch (e) {
      print('Erro ao adicionar item: $e');
    }
  }

  // Método para atualizar quantidade de um item
  static Future<bool> atualizarQuantidade(int produtoId, int novaQuantidade) async {
    if (_pedidoId == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/pedidos/$_pedidoId/itens/$produtoId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantidade': novaQuantidade}),
      );

      if (response.statusCode == 200) {
        // Atualiza a memória local
        final item = _itens.firstWhere(
          (item) => item['id'] == produtoId,
          orElse: () => {},
        );
        if (item.isNotEmpty) {
          item['quantidade'] = novaQuantidade;
        }
        return true;
      }
    } catch (e) {
      print('Erro ao atualizar quantidade: $e');
    }
    return false;
  }

  // Método para remover item do carrinho
  static Future<bool> removerItem(int produtoId) async {
    if (_pedidoId == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/pedidos/$_pedidoId/itens/$produtoId'),
      );

      if (response.statusCode == 200) {
        // Remove da memória local
        _itens.removeWhere((item) => item['id'] == produtoId);
        return true;
      }
    } catch (e) {
      print('Erro ao remover item: $e');
    }
    return false;
  }

  // Método privado para criar novo pedido
  static Future<void> _criarNovoPedido(int userId) async {
    try {
      // Primeiro verifica se já existe um pedido ativo
      final getResponse = await http.get(
        Uri.parse('$baseUrl/api/pedidos/usuario/$userId/ativo'),
        headers: {'Content-Type': 'application/json'},
      );

      if (getResponse.statusCode == 200) {
        final data = jsonDecode(getResponse.body);
        _pedidoId = data['id'];
        await carregarItens(); // Carrega os itens existentes
        return;
      }

      // Se não existe, cria um novo
      final response = await http.post(
        Uri.parse('$baseUrl/api/pedidos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_User': userId,
          'status': 'Carrinho',
          'valor_Total': 0,
          'observacoes': '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _pedidoId = data['id'];
      }
    } catch (e) {
      print('Erro ao criar pedido: $e');
    }
  }

  // Método para limpar carrinho
  static void limparCarrinho() {
    _pedidoId = null;
    _itens.clear();
  }

  // Método para calcular total
  static double calcularTotal() {
    return _itens.fold(
      0.0,
      (total, item) => total + ((item['preco_Unidade'] ?? 0) * (item['quantidade'] ?? 0)),
    );
  }

  // Método para obter quantidade total de itens
  static int getQuantidadeTotal() {
    return _itens.fold(0, (total, item) => total + (item['quantidade'] as int? ?? 0));
  }

  // Método para inicializar carrinho do usuário
  static Future<void> inicializarCarrinho(int userId) async {
    await _criarNovoPedido(userId);
  }
}