import 'package:flutter/material.dart';
import 'tela_orçamento.dart';

class TelaListaOrcamento extends StatelessWidget {
  const TelaListaOrcamento({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamento'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Nenhum orçamento adicionado',
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
            MaterialPageRoute(builder: (context) => const TelaOrcamento()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
