import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tela_convidados.dart';

class TelaListaConvidados extends StatefulWidget {
  const TelaListaConvidados({super.key});

  @override
  _TelaListaConvidadosState createState() => _TelaListaConvidadosState();
}

class _TelaListaConvidadosState extends State<TelaListaConvidados> {
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
            .orderBy('criadoEm', descending: true) 
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
              final nota = convidado['nota'] ?? 'Não informada';
              final tipoConvidado = convidado['tipoConvidado'];
              final genero = convidado['genero'];
              final telefone = convidado['telefone'] ?? 'Não informado';
              final email = convidado['email'] ?? 'Não informado';
              final endereco = convidado['endereco'] ?? 'Não informado';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('$nome $sobrenome'),
                  subtitle: Text('$tipoConvidado - $genero'),
                  trailing: const Icon(Icons.person),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('$nome $sobrenome'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nota: $nota'),
                            Text('Tipo: $tipoConvidado'),
                            Text('Gênero: $genero'),
                            Text('Telefone: $telefone'),
                            Text('Email: $email'),
                            Text('Endereço: $endereco'),
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
            MaterialPageRoute(builder: (context) => const TelaConvidados()),
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