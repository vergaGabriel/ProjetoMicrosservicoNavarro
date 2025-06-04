import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_urls.dart';

class AuthService {
  static int? userIdLogado;
  static bool isAdmin = false; 
  

  static Future<bool> cadastrarUsuario({
    required String nome,
    required String cpf,
    required String email,
    required String senha,
    String cargo = "client", // valor padrão
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiBaseUrls.user),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": nome,
          "cpf": cpf,
          "email": email,
          "senha": senha,
          "dataNascimento": "2000-01-01",
          "cargo": cargo,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Exceção: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loginUsuario({
    required String emailOuCpf,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiBaseUrls.user}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "emailOrCpf": emailOuCpf,
          "senha": senha,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userIdLogado = data['id'];
        isAdmin = (data['cargo'] == 'admin'); 
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  static void logout() {
    userIdLogado = null;
    isAdmin = false;
  }

}
