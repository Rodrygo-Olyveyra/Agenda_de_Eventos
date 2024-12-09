import 'package:flutter/material.dart';
import 'tela_fornecedores.dart';

class TelaListaFornecedores extends StatelessWidget {
  const TelaListaFornecedores({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Nenhum fornecedor adicionado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaFornecedor()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
