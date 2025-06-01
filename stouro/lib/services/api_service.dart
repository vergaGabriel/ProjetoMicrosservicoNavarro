import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5260/api/user';

  static int? userIdLogado; // <- Guarda o ID do usuário autenticado

  // Cadastro de usuário
  static Future<bool> cadastrarUsuario({
    required String nome,
    required String cpf,
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": nome,
          "cpf": cpf,
          "email": email,
          "senha": senha,
          "dataNascimento": "2000-01-01",
          "cargo": "client"
        }),
      );

      print('🔽 STATUS: ${response.statusCode}');
      print('🔽 BODY: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Erro ao cadastrar: $e');
      return false;
    }
  }

  // Login de usuário - agora retorna os dados do usuário
  static Future<Map<String, dynamic>?> loginUsuario({
    required String emailOuCpf,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "emailOrCpf": emailOuCpf,
          "senha": senha,
        }),
      );

      print('🔐 LOGIN STATUS: ${response.statusCode}');
      print('🔐 LOGIN BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userIdLogado = data['id']; // <-- Armazena o ID globalmente
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Erro no login: $e');
      return null;
    }
  }

  // Cadastro de produto
  static Future<bool> cadastrarProduto({
    required String nome,
    required String descricao,
    required double precoUnidade,
    required int estoque,
    String? variacoes,
    String? imagemUrl,
    required int criadoPorId,
  }) async {
    final url = Uri.parse('http://10.0.2.2:5182/api/produto');

    final body = json.encode({
      "nome": nome,
      "descricao": descricao,
      "preco_Unidade": precoUnidade,
      "estoque": estoque,
      "variacoes": variacoes ?? "",
      "imagemUrl": imagemUrl ?? "",
      "criado_Por_Id": criadoPorId,
      "data_Criacao": DateTime.now().toIso8601String(),
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint('🛒 STATUS: ${response.statusCode}');
      debugPrint('🛒 BODY: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Erro ao cadastrar produto: $e');
      return false;
    }
  }

  // Buscar produtos
  static Future<List<Map<String, dynamic>>> buscarProdutos() async {
    final url = Uri.parse('http://10.0.2.2:5182/api/produto');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);
        return lista.cast<Map<String, dynamic>>();
      } else {
        debugPrint('❌ Erro ao buscar produtos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Exceção ao buscar produtos: $e');
      return [];
    }
  }

  // Criar pedido
  static Future<int?> criarPedido({
    required int idUsuario,
    required int idEndereco,
    required double valorTotal,
    String status = "cart",
    String? observacoes,
  }) async {
    final url = Uri.parse('http://10.0.2.2:5207/api/pedidos');

    final body = jsonEncode({
      "id_User": idUsuario,
      "id_Endereco": idEndereco,
      "status": status,
      "valor_Total": valorTotal,
      "observacoes": observacoes ?? "",
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint('📦 Pedido STATUS: ${response.statusCode}');
      debugPrint('📦 Pedido BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('❌ Erro ao criar pedido: $e');
      return null;
    }
  }

  // Adicionar item ao pedido
  static Future<bool> adicionarItemPedido({
    required int pedidoId,
    required int produtoId,
    required int quantidade,
    required double precoUnitario,
  }) async {
    final url = Uri.parse('http://10.0.2.2:5207/api/itempedido');

    final body = jsonEncode({
      "pedidoId": pedidoId,
      "produtoId": produtoId,
      "quantidade": quantidade,
      "precoUnitario": precoUnitario
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint('🧾 ItemPedido STATUS: ${response.statusCode}');
      debugPrint('🧾 ItemPedido BODY: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Erro ao adicionar item ao pedido: $e');
      return false;
    }
  }
}
