import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_categoria.dart';
import 'telaeventos.dart';// Importar a tela de seleção de evento

class TelaFornecedor extends StatefulWidget {
  const TelaFornecedor({super.key});

  @override
  State<TelaFornecedor> createState() => _TelaFornecedorState();
}

class _TelaFornecedorState extends State<TelaFornecedor> {
  String categoriaSelecionada = 'Traje & Acessórios';
  String eventoSelecionado = ''; // Variável para armazenar o evento selecionado
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController notaController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController siteController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController montanteController = TextEditingController();

  Future<void> _adicionarFornecedor() async {
    if (nomeController.text.isEmpty || montanteController.text.isEmpty || eventoSelecionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
      return;
    }

    try {
      final fornecedoresRef = FirebaseFirestore.instance.collection('fornecedores');

      await fornecedoresRef.add({
        'nome': nomeController.text,
        'nota': notaController.text,
        'categoria': categoriaSelecionada,
        'evento': eventoSelecionado, // Adicionando o eventoId
        'telefone': telefoneController.text,
        'email': emailController.text,
        'site': siteController.text,
        'endereco': enderecoController.text,
        'montante': double.parse(montanteController.text),
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
        eventoSelecionado = ''; // Limpar a seleção de evento
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
            // Campo Nome
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Nota
            TextField(
              controller: notaController,
              decoration: const InputDecoration(
                labelText: 'Nota',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Seleção de Categoria
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

            // Campo Telefone
            TextField(
              controller: telefoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo E-mail
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Site
            TextField(
              controller: siteController,
              decoration: const InputDecoration(
                labelText: 'Site',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Endereço
            TextField(
              controller: enderecoController,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Montante
            TextField(
              controller: montanteController,
              decoration: const InputDecoration(
                labelText: 'Montante',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Seleção de Evento
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Evento'),
              subtitle: Text(eventoSelecionado.isNotEmpty ? eventoSelecionado : 'Nenhum evento selecionado'),
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

            // Botão Adicionar Fornecedor
            ElevatedButton(
              onPressed: _adicionarFornecedor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
