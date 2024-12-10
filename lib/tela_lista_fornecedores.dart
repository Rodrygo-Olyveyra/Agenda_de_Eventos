import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fornecedores')
            .orderBy('criadoEm', descending: true) // Ordena por data de criação
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum fornecedor adicionado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final fornecedores = snapshot.data!.docs;

          return ListView.builder(
            itemCount: fornecedores.length,
            itemBuilder: (context, index) {
              final fornecedor = fornecedores[index];

              // Obtendo os dados do fornecedor
              final nome = fornecedor['nome'] ?? 'Sem nome';
              final nota = fornecedor['nota'] ?? 'Sem nota';
              final telefone = fornecedor['telefone'] ?? 'Sem telefone';
              final email = fornecedor['email'] ?? 'Sem e-mail';
              final site = fornecedor['site'] ?? 'Sem site';
              final endereco = fornecedor['endereco'] ?? 'Sem endereço';
              final montante = fornecedor['montante'] ?? 0.0; // Garantir que seja numérico

              // Verifica se montante é um número válido antes de formatá-lo
              final montanteFormatado = montante is num
                  ? '\$${montante.toStringAsFixed(2)}'
                  : '\$0.00';

              return ListTile(
                title: Text(nome),
                subtitle: Text('Nota: $nota\nTelefone: $telefone\nE-mail: $email'),
                trailing: Text(montanteFormatado),
                onTap: () {
                  // Você pode adicionar uma navegação para detalhes ou editar fornecedor, por exemplo.
                  // Navigator.push(...);
                },
              );
            },
          );
        },
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
