import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_categoria.dart';
import 'telaeventos.dart';

class TelaFornecedor extends StatefulWidget {
  const TelaFornecedor({super.key});

  @override
  State<TelaFornecedor> createState() => _TelaFornecedorState();
}

class _TelaFornecedorState extends State<TelaFornecedor> {
  String categoriaSelecionada = 'Traje & Acessórios';
  String eventoSelecionado = '';
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController notaController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController siteController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController montanteController = TextEditingController();

  Future<void> _adicionarFornecedor() async {
    if (nomeController.text.isEmpty ||
        montanteController.text.isEmpty ||
        eventoSelecionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
      return;
    }

    double? montante = double.tryParse(montanteController.text);
    if (montante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um valor válido para o montante!')),
      );
      return;
    }

    try {
      final fornecedoresRef = FirebaseFirestore.instance.collection('fornecedores');

      await fornecedoresRef.add({
        'nome': nomeController.text,
        'nota': notaController.text,
        'categoria': categoriaSelecionada,
        'evento': eventoSelecionado,
        'telefone': telefoneController.text,
        'email': emailController.text,
        'site': siteController.text,
        'endereco': enderecoController.text,
        'montante': montante,
        'criadoEm': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fornecedor adicionado com sucesso!')),
      );

      nomeController.clear();
      notaController.clear();
      telefoneController.clear();
      emailController.clear();
      siteController.clear();
      enderecoController.clear();
      montanteController.clear();

      setState(() {
        categoriaSelecionada = 'Traje & Acessórios';
        eventoSelecionado = '';
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar fornecedor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Fornecedor'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: notaController,
              decoration: const InputDecoration(
                labelText: 'Nota',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categoria'),
              subtitle: Text(categoriaSelecionada),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final categoria = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaCategoria(),
                  ),
                );

                if (categoria != null && categoria.isNotEmpty) {
                  setState(() {
                    categoriaSelecionada = categoria;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: telefoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: siteController,
              decoration: const InputDecoration(
                labelText: 'Site',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: enderecoController,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: montanteController,
              decoration: const InputDecoration(
                labelText: 'Montante',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Evento'),
              subtitle: Text(eventoSelecionado.isNotEmpty
                  ? eventoSelecionado
                  : 'Nenhum evento selecionado'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final evento = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaSelecaoEvento(),
                  ),
                );

                if (evento != null && evento.isNotEmpty) {
                  setState(() {
                    eventoSelecionado = evento;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _adicionarFornecedor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('ADICIONAR'),
            ),
          ],
        ),
      ),
    );
  }
}
