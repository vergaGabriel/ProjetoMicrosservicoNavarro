import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/base_urls.dart';

class PedidoService {
  static Future<bool> finalizarCheckout({
    required int pedidoId,
    required String formaPagamento,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiBaseUrls.pedido}/checkout/$pedidoId')
,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'formaPgto': formaPagamento}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Erro em finalizarCheckout: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> buscarPedidoPorId(int pedidoId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiBaseUrls.pedido}/$pedidoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("Erro em buscarPedidoPorId: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> buscarUltimoPedidoDoUsuario(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiBaseUrls.pedido}/usuario/$usuarioId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final pedidos = jsonDecode(response.body) as List;
        if (pedidos.isNotEmpty) {
          return pedidos.last as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      print("Erro em buscarUltimoPedidoDoUsuario: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> buscarTodosPedidos() async {
    try {
      final response = await http.get(
        Uri.parse(ApiBaseUrls.pedido),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } catch (e) {
      print("Erro em buscarTodosPedidos: $e");
      return [];
    }
  }
  static Future<List<Map<String, dynamic>>> buscarPedidosPorUsuario(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiBaseUrls.pedido}/usuario/$usuarioId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return [];
    } catch (e) {
      print("Erro em buscarPedidosPorUsuario: $e");
      return [];
    }
  }

} 
