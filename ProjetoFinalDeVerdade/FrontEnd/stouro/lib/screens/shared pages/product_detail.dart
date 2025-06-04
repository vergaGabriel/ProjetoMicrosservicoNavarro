import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/produto_service.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late Map<String, dynamic> produto;
  bool get isAdmin => AuthService.isAdmin;

  // Para cliente
  int quantidade = 1;

  // Para admin
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nomeController;
  late TextEditingController descricaoController;
  late TextEditingController precoController;
  late TextEditingController estoqueController;
  late TextEditingController variacoesController;
  late TextEditingController imagemController;
  bool _salvando = false;

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  final args = ModalRoute.of(context)?.settings.arguments;
  if (args is! Map<String, dynamic>) {
    Navigator.pop(context);
    return;
  }

  produto = args;

  if (isAdmin) {
    nomeController = TextEditingController(text: produto['nome']);
    descricaoController = TextEditingController(text: produto['descricao']);
    precoController = TextEditingController(text: produto['preco_Unidade'].toString());
    estoqueController = TextEditingController(text: produto['estoque'].toString());
    variacoesController = TextEditingController(text: produto['variacoes'] ?? '');
    imagemController = TextEditingController(text: produto['imagem'] ?? '');
  }
}

  @override
  void dispose() {
    if (isAdmin) {
      nomeController.dispose();
      descricaoController.dispose();
      precoController.dispose();
      estoqueController.dispose();
      variacoesController.dispose();
      imagemController.dispose();
    }
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final sucesso = await ProdutoService.editarProduto(
      id: produto['id'],
      nome: nomeController.text.trim(),
      descricao: descricaoController.text.trim(),
      precoUnidade: double.tryParse(precoController.text.trim()) ?? 0.0,
      estoque: int.tryParse(estoqueController.text.trim()) ?? 0,
      variacoes: variacoesController.text.trim().isEmpty ? null : variacoesController.text.trim(),
      imagem: imagemController.text.trim().isEmpty ? null : imagemController.text.trim(),
    );

    setState(() => _salvando = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso ? '✅ Produto atualizado com sucesso!' : '❌ Erro ao atualizar produto'),
      backgroundColor: sucesso ? Colors.green : Colors.red,
    ));

    if (sucesso) Navigator.pop(context, true); 

  }

  @override
  Widget build(BuildContext context) {
    final preco = (produto['preco_Unidade'] is String)
        ? double.tryParse(produto['preco_Unidade']) ?? 0.0
        : produto['preco_Unidade'] ?? 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true), // <-- agora sinaliza que algo pode ter mudado
        ),
        title: Text(isAdmin ? 'Editar Produto' : produto['nome']),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: isAdmin ? _buildAdminForm() : _buildUserView(preco),
        ),
      ),
    );
  }

  Widget _buildUserView(double preco) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                (produto['imagem'] ?? '').toString(),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white54, size: 60),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto['nome'] ?? 'Produto',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${preco.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, color: Color(0xFF8A4DFF), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  produto['descricao'] ?? 'Sem descrição disponível',
                  style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Quantidade:', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: quantidade > 1 ? () => setState(() => quantidade--) : null,
                            icon: const Icon(Icons.remove, color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '$quantidade',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: quantidade < (produto['estoque'] ?? 99)
                                ? () => setState(() => quantidade++)
                                : null,
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      CartService.adicionarItem(produto, quantidade);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('✅ $quantidade ${quantidade > 1 ? "itens" : "item"} adicionados ao carrinho!'),
                        backgroundColor: Colors.green,
                      ));
                      setState(() => quantidade = 1);
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    label: Text(
                      'Adicionar ao Carrinho (${quantidade}x)',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4DFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imagemController.text,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildField('Nome', nomeController, Icons.title),
            _buildField('Descrição', descricaoController, Icons.description, maxLines: 3),
            Row(
              children: [
                Expanded(child: _buildField('Preço (R\$)', precoController, Icons.attach_money, tipo: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Estoque', estoqueController, Icons.inventory, tipo: TextInputType.number)),
              ],
            ),
            _buildOptionalField('Variações', variacoesController, Icons.color_lens),
            _buildOptionalField('Imagem (URL)', imagemController, Icons.image),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salvarAlteracoes,
                icon: _salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _salvando ? 'Salvando...' : 'Salvar Alterações',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A4DFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {TextInputType tipo = TextInputType.text, int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: const Color(0xFF8A4DFF)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildOptionalField(String label, TextEditingController controller, IconData icon,
      {TextInputType tipo = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.white),
        validator: (_) => null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: const Color(0xFF8A4DFF)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}
