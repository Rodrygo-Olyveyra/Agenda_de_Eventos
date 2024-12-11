import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tela_orçamento.dart';

class TelaListaOrcamento extends StatefulWidget {
  const TelaListaOrcamento({super.key});

  @override
  _TelaListaOrcamentoState createState() => _TelaListaOrcamentoState();
}

class _TelaListaOrcamentoState extends State<TelaListaOrcamento> {
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
              final nome = orcamento['nome'] ?? 'Sem nome';
              final nota = orcamento['nota'] ?? 'Sem nota';
              final categoria = orcamento['categoria'] ?? 'Sem categoria';
              final montante = orcamento['montante'] ?? 0.0;

              final montanteFormatado = montante is num
                  ? 'R\$ ${montante.toStringAsFixed(2)}'
                  : 'R\$ 0.00';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text('Nota: $nota\nCategoria: $categoria\nMontante: $montanteFormatado'),
                  trailing: const Icon(Icons.attach_money),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(nome),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nota: $nota'),
                            Text('Categoria: $categoria'),
                            Text('Montante: $montanteFormatado'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaOrcamento()),
          );

          if (resultado == true) {
            setState(() {}); 
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
