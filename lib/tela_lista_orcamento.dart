import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orcamento')
            .orderBy('criadoEm', descending: true) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar os orçamentos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum orçamento adicionado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final orcamentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orcamentos.length,
            itemBuilder: (context, index) {
              final orcamento = orcamentos[index];
              final nome = orcamento['nome'];
              final nota = orcamento['nota'];
              final categoria = orcamento['categoria'];
              final montante = orcamento['montante'].toString();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text('$nota - Categoria: $categoria\nMontante: R\$ $montante'),
                  trailing: const Icon(Icons.attach_money),
                  onTap: () {

                  },
                ),
              );
            },
          );
        },
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
