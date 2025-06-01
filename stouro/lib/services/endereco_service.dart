import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/adress_model.dart';

class EnderecoService {
  static const String baseUrl = 'http://10.0.2.2:5154/api/enderecos';

  // Buscar todos os endereços de um usuário
  static Future<List<EnderecoEntrega>> buscarEnderecos(int idUsuario) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/$idUsuario'),
    );

    debugPrint('📦 Dados recebidos do backend: ${response.body}');

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => EnderecoEntrega.fromJson(e)).toList();
    } else {
      debugPrint('❌ Erro ao buscar endereços: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    debugPrint('❌ Exceção ao buscar endereços: $e');
    return [];
  }
}

  // Adicionar novo endereço
  static Future<bool> adicionarEndereco(EnderecoEntrega endereco) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(endereco.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Erro ao adicionar endereço: $e');
      return false;
    }
  }

  // Atualizar endereço existente
  static Future<bool> atualizarEndereco(int id, EnderecoEntrega endereco) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(endereco.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar endereço: $e');
      return false;
    }
  }

  // Remover endereço
  static Future<bool> removerEndereco(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Erro ao remover endereço: $e');
      return false;
    }
  }
}
