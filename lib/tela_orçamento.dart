import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tela_categoria.dart';

class TelaOrcamento extends StatefulWidget {
  const TelaOrcamento({super.key});

  @override
  State<TelaOrcamento> createState() => _TelaOrcamentoState();
}

class _TelaOrcamentoState extends State<TelaOrcamento> {
  String categoriaSelecionada = 'Traje & Acessórios'; 
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController notaController = TextEditingController();
  final TextEditingController montanteController = TextEditingController();

  Future<void> _adicionarOrcamento() async {
    final nome = nomeController.text;
    final nota = notaController.text;
    final montante = montanteController.text;

    if (nome.isNotEmpty && nota.isNotEmpty && montante.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('orcamento').add({
          'nome': nome,
          'nota': nota,
          'categoria': categoriaSelecionada,
          'montante': double.tryParse(montante) ?? 0.0,
          'criadoEm': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orçamento adicionado com sucesso!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar orçamento: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicione um custo novo'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: Padding(
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
              controller: montanteController,
              decoration: const InputDecoration(
                labelText: 'Montante',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _adicionarOrcamento,
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
