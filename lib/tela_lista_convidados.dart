import 'package:flutter/material.dart';
import 'tela_convidados.dart';

class TelaListaConvidados extends StatelessWidget {
  const TelaListaConvidados({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convidadods'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Nenhum convidado adicionado',
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
            MaterialPageRoute(builder: (context) => const TelaConvidados()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
