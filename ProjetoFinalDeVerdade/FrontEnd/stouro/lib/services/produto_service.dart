import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_urls.dart';

class ProdutoService {
  /// Cadastra um novo produto (POST /api/produto)
  static Future<bool> cadastrarProduto({
    required String nome,
    required String descricao,
    required double precoUnidade,
    required int estoque,
    String? variacoes,
    String? imagem,
    required int criadoPorId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiBaseUrls.produto),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": nome,
          "descricao": descricao,
          "preco_Unidade": precoUnidade,
          "estoque": estoque,
          "variacoes": variacoes?.trim() ?? "",
          "imagem": imagem?.trim() ?? "",
          "criado_Por_Id": criadoPorId,
          "data_Criacao": DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Erro ao cadastrar produto: $e');
      return false;
    }
  }

  /// Edita um produto existente (PUT /api/produto/{id})
  static Future<bool> editarProduto({
    required int id,
    required String nome,
    required String descricao,
    required double precoUnidade,
    required int estoque,
    String? variacoes,
    String? imagem,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiBaseUrls.produto}/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": id,
          "nome": nome,
          "descricao": descricao,
          "preco_Unidade": precoUnidade,
          "estoque": estoque,
          "variacoes": variacoes?.trim() ?? "",
          "imagem": imagem?.trim() ?? "",
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao editar produto: $e');
      return false;
    }
  }

  /// Busca todos os produtos (GET /api/produto)
  static Future<List<Map<String, dynamic>>> buscarProdutos() async {
    try {
      final response = await http.get(Uri.parse(ApiBaseUrls.produto));
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      return [];
    }
  }

  /// Busca um único produto por ID (GET /api/produto/{id})
  static Future<Map<String, dynamic>?> buscarProdutoPorId(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiBaseUrls.produto}/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar produto por ID: $e');
      return null;
    }
  }

  /// Atualiza o estoque dos produtos após checkout (PUT /api/produto/estoque)
  static Future<bool> atualizarEstoque({
    required int pedidoId,
    required int usuarioId,
    required String formaPgto,
    required List<Map<String, dynamic>> itens,
  }) async {
    try {
      final body = jsonEncode({
        "pedidoId": pedidoId,
        "usuarioId": usuarioId,
        "formaPgto": formaPgto,
        "itens": itens.map((item) => {
          "produtoId": item["produtoId"],
          "quantidade": item["quantidade"],
        }).toList(),
      });

      final response = await http.put(
        Uri.parse('${ApiBaseUrls.produto}/estoque'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("🔁 Atualizar estoque status: ${response.statusCode}");
      print("📦 Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erro ao atualizar estoque: $e');
      return false;
    }
  }
}
