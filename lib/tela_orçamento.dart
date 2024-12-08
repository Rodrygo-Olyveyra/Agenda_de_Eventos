import 'package:flutter/material.dart';
import 'tela_categoria.dart';

class TelaOrcamento extends StatefulWidget {
  const TelaOrcamento({super.key});

  @override
  State<TelaOrcamento> createState() => _TelaOrcamentoState();
}

class _TelaOrcamentoState extends State<TelaOrcamento> {
  String categoriaSelecionada = 'Traje & Acessórios'; // Categoria inicial padrão

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
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
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
                // Navega para a TelaCategoria e espera a seleção
                final categoria = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaCategoria(),
                  ),
                );

                // Atualiza a categoria selecionada, caso o usuário escolha
                if (categoria != null && categoria.isNotEmpty) {
                  setState(() {
                    categoriaSelecionada = categoria;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Montante',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Lógica para adicionar o custo
              },
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
