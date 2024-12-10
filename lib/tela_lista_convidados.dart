import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tela_convidados.dart';

class TelaListaConvidados extends StatelessWidget {
  const TelaListaConvidados({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convidados'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('convidados')
            .orderBy('criadoEm', descending: true) // Ordena pela data de criação
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar os convidados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum convidado adicionado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final convidados = snapshot.data!.docs;

          return ListView.builder(
            itemCount: convidados.length,
            itemBuilder: (context, index) {
              final convidado = convidados[index];
              final nome = convidado['nome'];
              final sobrenome = convidado['sobrenome'];
              final tipoConvidado = convidado['tipoConvidado'];
              final genero = convidado['genero'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('$nome $sobrenome'),
                  subtitle: Text('$tipoConvidado - $genero'),
                  trailing: const Icon(Icons.person),
                  onTap: () {
                    // Ação ao clicar na lista de convidados
                    // Você pode adicionar uma página de detalhes, se necessário.
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
            MaterialPageRoute(builder: (context) => const TelaConvidados()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
