import 'package:flutter/material.dart';
import '../models/adress_model.dart';
import '../services/endereco_service.dart';
import '../services/api_service.dart'; // ✅ IMPORTADO para acessar userIdLogado

class AddressManagementPage extends StatefulWidget {
  const AddressManagementPage({super.key});

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  List<EnderecoEntrega> enderecos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarEnderecos();
  }

  Future<void> carregarEnderecos() async {
    final int userId = ApiService.userIdLogado ?? 0;
    final lista = await EnderecoService.buscarEnderecos(userId);
    setState(() {
      enderecos = lista;
      carregando = false;
    });
  }

  void abrirFormulario({EnderecoEntrega? enderecoExistente}) {
    final isEditar = enderecoExistente != null;
    final int userId = ApiService.userIdLogado ?? 0;

    final apelidoCtrl = TextEditingController(text: enderecoExistente?.apelido ?? '');
    final destinatarioCtrl = TextEditingController(text: enderecoExistente?.destinatario ?? '');
    final telefoneCtrl = TextEditingController(text: enderecoExistente?.telefone ?? '');
    final ruaCtrl = TextEditingController(text: enderecoExistente?.rua ?? '');
    final numeroCtrl = TextEditingController(text: enderecoExistente?.numero ?? '');
    final complementoCtrl = TextEditingController(text: enderecoExistente?.complemento ?? '');
    final bairroCtrl = TextEditingController(text: enderecoExistente?.bairro ?? '');
    final cidadeCtrl = TextEditingController(text: enderecoExistente?.cidade ?? '');
    final estadoCtrl = TextEditingController(text: enderecoExistente?.estado ?? '');
    final cepCtrl = TextEditingController(text: enderecoExistente?.cep ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        scrollable: true,
        title: Text(isEditar ? 'Editar Endereço' : 'Novo Endereço'),
        content: Column(
          children: [
            TextField(controller: apelidoCtrl, decoration: const InputDecoration(labelText: 'Apelido')),
            TextField(controller: destinatarioCtrl, decoration: const InputDecoration(labelText: 'Destinatário')),
            TextField(controller: telefoneCtrl, decoration: const InputDecoration(labelText: 'Telefone')),
            TextField(controller: ruaCtrl, decoration: const InputDecoration(labelText: 'Rua')),
            TextField(controller: numeroCtrl, decoration: const InputDecoration(labelText: 'Número')),
            TextField(controller: complementoCtrl, decoration: const InputDecoration(labelText: 'Complemento')),
            TextField(controller: bairroCtrl, decoration: const InputDecoration(labelText: 'Bairro')),
            TextField(controller: cidadeCtrl, decoration: const InputDecoration(labelText: 'Cidade')),
            TextField(controller: estadoCtrl, decoration: const InputDecoration(labelText: 'Estado')),
            TextField(controller: cepCtrl, decoration: const InputDecoration(labelText: 'CEP')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final novo = EnderecoEntrega(
                id: enderecoExistente?.id ?? 0,
                idUsuario: userId,
                apelido: apelidoCtrl.text,
                destinatario: destinatarioCtrl.text,
                telefone: telefoneCtrl.text,
                rua: ruaCtrl.text,
                numero: numeroCtrl.text,
                complemento: complementoCtrl.text,
                bairro: bairroCtrl.text,
                cidade: cidadeCtrl.text,
                estado: estadoCtrl.text,
                cep: cepCtrl.text,
              );

              bool ok = isEditar
                  ? await EnderecoService.atualizarEndereco(novo.id, novo)
                  : await EnderecoService.adicionarEndereco(novo);

              if (ok) {
                Navigator.pop(context);
                carregarEnderecos();
              }
            },
            child: Text(isEditar ? 'Salvar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> removerEndereco(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover endereço'),
        content: const Text('Tem certeza que deseja remover este endereço?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await EnderecoService.removerEndereco(id);
      if (ok) carregarEnderecos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Endereços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => abrirFormulario(),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : enderecos.isEmpty
              ? const Center(child: Text('Nenhum endereço cadastrado.'))
              : ListView.builder(
                  itemCount: enderecos.length,
                  itemBuilder: (_, i) {
                    final e = enderecos[i];
                    return ListTile(
                      title: Text('${e.apelido} - ${e.rua}, ${e.numero}'),
                      subtitle: Text('${e.cidade}, ${e.estado} - CEP: ${e.cep}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => abrirFormulario(enderecoExistente: e),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removerEndereco(e.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
