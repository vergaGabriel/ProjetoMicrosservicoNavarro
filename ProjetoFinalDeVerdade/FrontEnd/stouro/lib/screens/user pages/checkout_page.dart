import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/pedido_service.dart';
import '../../services/cart_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _formaPagamento;
  String _enderecoSelecionado = "Retirar na loja";
  bool _processando = false;

  Future<void> _finalizarCompra() async {
    if (_formaPagamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Selecione a forma de pagamento.')),
      );
      return;
    }

    setState(() => _processando = true);

    final userId = AuthService.userIdLogado;
    if (userId == null) {
      setState(() => _processando = false);
      return;
    }

    final pedido = await PedidoService.buscarUltimoPedidoDoUsuario(userId);
    final pedidoId = pedido?['id'];

    if (pedidoId == null) {
      setState(() => _processando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Nenhum pedido pendente encontrado.')),
      );
      return;
    }

    final sucesso = await PedidoService.finalizarCheckout(
      pedidoId: pedidoId,
      formaPagamento: _formaPagamento!,
    );

    if (sucesso) {
      await CartService.limparCarrinho();
      _mostrarConfirmacao();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Erro ao finalizar pedido.')),
      );
    }

    setState(() => _processando = false);
  }

  void _mostrarConfirmacao() {
    final codigo = switch (_formaPagamento) {
      'Pix' => 'PIX-${Random().nextInt(999999)}',
      'Boleto' => 'BOL-${Random().nextInt(999999)}',
      'Cartão de Crédito' => 'CARD-${Random().nextInt(999999)}',
      _ => 'N/A',
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('✅ Pedido Confirmado', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Endereço: $_enderecoSelecionado', style: const TextStyle(color: Colors.white)),
            Text('Forma de pagamento: $_formaPagamento', style: const TextStyle(color: Colors.white)),
            Text('Código: $codigo', style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/products', (_) => false,
            ),
            child: const Text('Voltar para loja', style: TextStyle(color: Colors.purpleAccent)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
        centerTitle: true,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Endereço de Entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                const SizedBox(height: 8),
                _styledContainer(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Colors.black87,
                    value: _enderecoSelecionado,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: "Retirar na loja", child: Text("Retirar na loja", style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Forma de Pagamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                const SizedBox(height: 8),
                _styledContainer(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Colors.black87,
                    value: _formaPagamento,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: "Pix", child: Text("Pix", style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: "Boleto", child: Text("Boleto", style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: "Cartão de Crédito", child: Text("Cartão de Crédito", style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (value) => setState(() => _formaPagamento = value),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _processando ? null : _finalizarCompra,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4DFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _processando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('CONFIRMAR PEDIDO', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      border: InputBorder.none,
    );
  }
}
