import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final precoController = TextEditingController();
  final estoqueController = TextEditingController();
  final variacoesController = TextEditingController();
  final imagemUrlController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    precoController.dispose();
    estoqueController.dispose();
    variacoesController.dispose();
    imagemUrlController.dispose();
    super.dispose();
  }

  void _salvarProduto() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _salvando = true);

      final nome = nomeController.text.trim();
      final descricao = descricaoController.text.trim();
      final preco = double.tryParse(precoController.text.trim()) ?? 0.0;
      final estoque = int.tryParse(estoqueController.text.trim()) ?? 0;
      final variacoes = variacoesController.text.trim();
      final imagemUrl = imagemUrlController.text.trim();

      final sucesso = await ApiService.cadastrarProduto(
        nome: nome,
        descricao: descricao,
        precoUnidade: preco,
        estoque: estoque,
        variacoes: variacoes,
        imagemUrl: imagemUrl,
        criadoPorId: 1,
      );

      setState(() => _salvando = false);

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Produto cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao cadastrar produto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Adicionar Produto'),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_box, color: Color(0xFF8A4DFF), size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Novo Produto',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Preencha as informações do produto',
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
                
                const SizedBox(height: 24),
                
                // Formulário
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: nomeController,
                        label: 'Nome do Produto',
                        icon: Icons.inventory,
                        hint: 'Ex: Camiseta Premium',
                      ),
                      _buildTextField(
                        controller: descricaoController,
                        label: 'Descrição',
                        icon: Icons.description,
                        hint: 'Descreva o produto detalhadamente',
                        maxLines: 3,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: precoController,
                              label: 'Preço (R\$)',
                              icon: Icons.attach_money,
                              hint: '0.00',
                              tipo: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: estoqueController,
                              label: 'Estoque',
                              icon: Icons.inventory_2,
                              hint: '0',
                              tipo: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        controller: variacoesController,
                        label: 'Variações',
                        icon: Icons.palette,
                        hint: 'Ex: Azul, Vermelho, P, M, G',
                      ),
                      _buildTextField(
                        controller: imagemUrlController,
                        label: 'URL da Imagem',
                        icon: Icons.image,
                        hint: 'https://exemplo.com/imagem.jpg',
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botão salvar
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _salvando ? null : _salvarProduto,
                          icon: _salvando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            _salvando ? 'Salvando...' : 'Salvar Produto',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A4DFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType tipo = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.black.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            controller: controller,
            keyboardType: tipo,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            validator: (value) => value == null || value.isEmpty
                ? 'Preencha o campo $label'
                : null,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: Icon(icon, color: const Color(0xFF8A4DFF)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8A4DFF), width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}