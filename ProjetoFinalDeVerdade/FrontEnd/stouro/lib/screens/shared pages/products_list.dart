import 'package:flutter/material.dart';
import '../../services/produto_service.dart';
import '../../services/cart_service.dart';

class ProductsSharedPage extends StatefulWidget {
  final bool isAdmin;

  const ProductsSharedPage({super.key, required this.isAdmin});

  @override
  State<ProductsSharedPage> createState() => _ProductsSharedPageState();
}

class _ProductsSharedPageState extends State<ProductsSharedPage> {
  List<Map<String, dynamic>> produtos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    final resultado = await ProdutoService.buscarProdutos();
    setState(() {
      produtos = resultado;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: widget.isAdmin, // ✅ mostra a seta só se for admin
        actions: [
          if (!widget.isAdmin)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/cart');
                    setState(() {});
                  },
                ),
                if (CartService.listarItens().isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${CartService.listarItens().fold(0, (sum, item) => sum + (item['quantidade'] as int))}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
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
        child: carregando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8A4DFF)),
              )
            : Column(
                children: [
                  const SizedBox(height: kToolbarHeight + 16),
                  _buildBoasVindas(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: produtos.isEmpty
                        ? _buildVazio()
                        : _buildGridProdutos(),
                  ),
                  if (widget.isAdmin)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/admin_add_product');
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Adicionar Produto',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A4DFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                        ),
                      ),
                    )
                  else
                    SafeArea(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/dashboard',
                              arguments: {'isAdmin': false},
                            ),
                            icon: const Icon(Icons.person, color: Colors.white),
                            label: const Text(
                              'Ver meu perfil e pedidos',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8A4DFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildBoasVindas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Color(0xFF8A4DFF), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isAdmin
                  ? 'Gerencie os produtos da loja'
                  : 'Bem-vindo à Stouro! Encontre os melhores produtos aqui',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVazio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.white54),
          SizedBox(height: 16),
          Text('Nenhum produto disponível', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 8),
          Text('Novos produtos serão adicionados em breve', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildGridProdutos() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        final produto = produtos[index];
        return GestureDetector(
          onTap: () async {
            final rota = '/product_detail';
            final alterado = await Navigator.pushNamed(context, rota, arguments: produto);
            if (alterado == true) setState(() {}); // força rebuild pra atualizar o badge
          },
          child: Card(
            color: Colors.black.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      produto['imagem'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto['nome'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${produto['preco_Unidade'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF8A4DFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (produto['estoque'] != null && produto['estoque'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Estoque: ${produto['estoque']}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

