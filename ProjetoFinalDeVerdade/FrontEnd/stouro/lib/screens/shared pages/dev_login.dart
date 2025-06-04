import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
final mockProduto = {
  'id': 999,
  'nome': 'Produto Teste',
  'descricao': 'Este é um produto de teste gerado manualmente.',
  'preco_Unidade': 19.99,
  'estoque': 5,
  'variacoes': 'Cor: Azul',
  'imagem': 'https://via.placeholder.com/300x200.png?text=Produto+Teste',
};


class DevLoginPage extends StatelessWidget {
  const DevLoginPage({super.key});

  void _entrarComoAdmin(BuildContext context) {
    AuthService.isAdmin = true;
    Navigator.pushReplacementNamed(
        context,
        '/product_detail',
        arguments: mockProduto,
      );
  }

  Future<void> _entrarComoUsuario(BuildContext context) async {
    final resultado = await AuthService.loginUsuario(
      emailOuCpf: 'kl@gmail.com',
      senha: 'Senha123',
    );

    if (resultado != null) {
      Navigator.pushReplacementNamed(
        context,
        '/product_detail',
        arguments: mockProduto,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Falha ao entrar como usuário'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('🧪 DevLoginPage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _entrarComoUsuario(context),
                  icon: const Icon(Icons.person),
                  label: const Text('Entrar como Usuário'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4DFF),
                    minimumSize: const Size(220, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _entrarComoAdmin(context),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Entrar como Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    minimumSize: const Size(220, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
