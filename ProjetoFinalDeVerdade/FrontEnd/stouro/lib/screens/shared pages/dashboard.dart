import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_option.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = AuthService.isAdmin;
    final List<DashboardOption> opcoes = DashboardService.getOptions(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Painel de Controle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !AuthService.isAdmin, // ✅ mostra a seta só se NÃO for admin
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildUserHeader(isAdmin),
                const SizedBox(height: 32),
                _buildDashboardOptions(context, opcoes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(bool isAdmin) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8A4DFF), Color(0xFFB084FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8A4DFF).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          isAdmin ? 'Administrador' : 'Usuário Stouro',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8A4DFF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isAdmin ? 'Painel Administrativo' : 'Cliente Premium',
            style: const TextStyle(
              color: Color(0xFF8A4DFF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardOptions(BuildContext context, List<DashboardOption> opcoes) {
    return Column(
      children: [
        for (final opcao in opcoes) ...[
          _buildMenuCard(context, opcao),
          const SizedBox(height: 16),
        ],
        _buildLogoutCard(context),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, DashboardOption opcao) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // <-- ESSENCIAL
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF8A4DFF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(opcao.icon, color: const Color(0xFF8A4DFF), size: 24),
        ),
        title: Text(
          opcao.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          if (opcao.action != null) {
            opcao.action!();
          } else if (opcao.route != null) {
            Navigator.pushNamed(context, opcao.route!);
          }
        },
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // 👈 importante
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.logout, color: Colors.red),
        ),
        title: const Text(
          'Sair da Conta',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Desconectar do aplicativo', style: TextStyle(color: Colors.red)),
        onTap: () => _confirmarLogout(context),
      ),
    );
  }


  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Sair da Conta', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza que deseja sair da sua conta?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
