import 'package:flutter/material.dart';
import '../models/adress_model.dart';
import '../services/endereco_service.dart';
import '../services/api_service.dart';
import 'dart:math';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<EnderecoEntrega> _enderecos = [];
  EnderecoEntrega? _enderecoSelecionado;
  String? _formaPagamento;
  bool _processandoPagamento = false;

  // Controladores para cartão de crédito
  final _numeroCartaoController = TextEditingController();
  final _nomeCartaoController = TextEditingController();
  final _validadeController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarEnderecos();
  }

  @override
  void dispose() {
    _numeroCartaoController.dispose();
    _nomeCartaoController.dispose();
    _validadeController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _carregarEnderecos() async {
    final idUsuario = ApiService.userIdLogado;
    if (idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Usuário não está logado.')),
      );
      return;
    }

    final lista = await EnderecoService.buscarEnderecos(idUsuario);
    setState(() {
      _enderecos = lista;
      _enderecoSelecionado = lista.isNotEmpty ? lista.first : null;
    });
  }

  String _gerarCodigoPix() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _gerarCodigoBoleto() {
    final random = Random();
    return '${1073900000000000000 + random.nextInt(999999999)}';
  }

  Future<void> _processarPagamento() async {
    if (_formaPagamento == 'Cartão de Crédito') {
      if (_numeroCartaoController.text.length < 16 ||
          _nomeCartaoController.text.isEmpty ||
          _validadeController.text.length < 5 ||
          _cvvController.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Preencha todos os dados do cartão corretamente')),
        );
        return;
      }
    }

    setState(() => _processandoPagamento = true);

    // Simula processamento
    await Future.delayed(const Duration(seconds: 3));

    setState(() => _processandoPagamento = false);

    _mostrarConfirmacaoPagamento();
  }

  void _mostrarConfirmacaoPagamento() {
    String codigoTransacao = '';
    String instrucoes = '';
    IconData icone = Icons.check_circle;
    Color corIcone = Colors.green;

    switch (_formaPagamento) {
      case 'Pix':
        codigoTransacao = _gerarCodigoPix();
        icone = Icons.pix;
        corIcone = Colors.green;
        instrucoes = 'Use o código PIX abaixo para finalizar o pagamento:\n\n$codigoTransacao\n\nVálido por 30 minutos. O QR Code foi enviado por email.';
        break;
      case 'Boleto':
        codigoTransacao = _gerarCodigoBoleto();
        icone = Icons.receipt;
        corIcone = Colors.orange;
        instrucoes = 'Código de barras do boleto:\n\n$codigoTransacao\n\nO boleto foi enviado para seu email e vence em 3 dias úteis.';
        break;
      case 'Cartão de Crédito':
        codigoTransacao = 'CARD${Random().nextInt(999999).toString().padLeft(6, '0')}';
        icone = Icons.credit_card;
        corIcone = Colors.blue;
        instrucoes = 'Pagamento aprovado!\n\nCódigo da transação: $codigoTransacao\n\nO comprovante foi enviado para seu email.';
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icone, color: corIcone, size: 28),
            const SizedBox(width: 8),
            const Text('Pedido Confirmado!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Seu pedido foi processado com sucesso!',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Endereço de entrega:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${_enderecoSelecionado!.rua}, ${_enderecoSelecionado!.numero}\n${_enderecoSelecionado!.bairro}, ${_enderecoSelecionado!.cidade} - ${_enderecoSelecionado!.estado}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                'Forma de pagamento: $_formaPagamento',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instruções de Pagamento:',
                      style: TextStyle(
                        color: corIcone,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      instrucoes,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8A4DFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximos passos:',
                      style: TextStyle(
                        color: Color(0xFF8A4DFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Você receberá uma confirmação por email\n• Acompanhe o status do pedido em "Meu Perfil"\n• Estimativa de entrega: 3-5 dias úteis',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/profile',
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Ver Pedidos',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/products',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4DFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Continuar Comprando',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _finalizarCompra() {
    if (_enderecoSelecionado == null || _formaPagamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Selecione o endereço e a forma de pagamento')),
      );
      return;
    }

    _processarPagamento();
  }

  Widget _buildFormularioCartao() {
    return Card(
      color: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.credit_card, color: Color(0xFF8A4DFF)),
                SizedBox(width: 8),
                Text(
                  'Dados do Cartão',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroCartaoController,
              keyboardType: TextInputType.number,
              maxLength: 19,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                // Formatação automática do número do cartão
                String formatted = value.replaceAll(' ', '');
                if (formatted.length <= 16) {
                  formatted = formatted.replaceAllMapped(
                    RegExp(r'.{4}'),
                    (match) => '${match.group(0)} ',
                  ).trim();
                }
                if (formatted != value) {
                  _numeroCartaoController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              decoration: InputDecoration(
                labelText: 'Número do Cartão',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: '1234 5678 9012 3456',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF8A4DFF)),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomeCartaoController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome no Cartão',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Como impresso no cartão',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person, color: Color(0xFF8A4DFF)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _validadeController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      if (value.length == 2 && !value.contains('/')) {
                        _validadeController.text = '$value/';
                        _validadeController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _validadeController.text.length),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Validade',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'MM/AA',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF8A4DFF)),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: '123',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.security, color: Color(0xFF8A4DFF)),
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
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
          child: _enderecos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 80,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum endereço cadastrado',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Adicione um endereço para finalizar sua compra',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                        icon: const Icon(Icons.add_location, color: Colors.white),
                        label: const Text(
                          'Gerenciar Endereços',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A4DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_bag, color: Color(0xFF8A4DFF), size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Finalizar Pedido',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Escolha o endereço e forma de pagamento',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Endereço de entrega
                      Card(
                        color: Colors.black.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.location_on, color: Color(0xFF8A4DFF)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Endereço de Entrega',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<EnderecoEntrega>(
                                dropdownColor: Colors.grey[900],
                                iconEnabledColor: Colors.white,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.home, color: Color(0xFF8A4DFF)),
                                ),
                                value: _enderecoSelecionado,
                                items: _enderecos.map((endereco) {
                                  return DropdownMenuItem(
                                    value: endereco,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          endereco.apelido,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${endereco.rua}, ${endereco.numero} - ${endereco.bairro}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _enderecoSelecionado = value),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Forma de pagamento
                      Card(
                        color: Colors.black.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.payment, color: Color(0xFF8A4DFF)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Forma de Pagamento',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.grey[900],
                                iconEnabledColor: Colors.white,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF8A4DFF)),
                                ),
                                value: _formaPagamento,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Pix',
                                    child: Row(
                                      children: [
                                        Icon(Icons.pix, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Pix - Aprovação instantânea', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Boleto',
                                    child: Row(
                                      children: [
                                        Icon(Icons.receipt, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Boleto - Vence em 3 dias', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cartão de Crédito',
                                    child: Row(
                                      children: [
                                        Icon(Icons.credit_card, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Cartão de Crédito', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) => setState(() {
                                  _formaPagamento = value;
                                  // Limpa os campos do cartão ao trocar para outra forma
                                  if (value != 'Cartão de Crédito') {
                                    _numeroCartaoController.clear();
                                    _nomeCartaoController.clear();
                                    _validadeController.clear();
                                    _cvvController.clear();
                                  }
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Formulário do cartão de crédito
                      if (_formaPagamento == 'Cartão de Crédito') ...[
                        const SizedBox(height: 16),
                        _buildFormularioCartao(),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Botão finalizar
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _processandoPagamento ? null : _finalizarCompra,
                          icon: _processandoPagamento
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle, color: Colors.white),
                          label: Text(
                            _processandoPagamento ? 'Processando...' : 'Confirmar Pedido',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _processandoPagamento 
                                ? Colors.grey 
                                : const Color(0xFF8A4DFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}