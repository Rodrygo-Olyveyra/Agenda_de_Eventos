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
            .orderBy('criadoEm', descending: true) // Ordenar por data de criação
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

          // Agrupar convidados por eventoId
          Map<String, List<DocumentSnapshot>> convidadosPorEvento = {};

          for (var convidado in convidados) {
            final eventoId = convidado['eventoId']; // Verifique se o campo existe

            if (eventoId == null) {
              continue; // Ignorar convidados sem eventoId
            }

            if (!convidadosPorEvento.containsKey(eventoId)) {
              convidadosPorEvento[eventoId] = [];
            }

            convidadosPorEvento[eventoId]!.add(convidado);
          }

          // Exibir os convidados agrupados por evento
          return ListView(
            children: convidadosPorEvento.entries.map((entry) {
              final eventoId = entry.key;
              final convidadosDoEvento = entry.value;

              // Buscar o evento para obter o nome (campo 'event')
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('events').doc(eventoId).get(),
                builder: (context, eventoSnapshot) {
                  if (eventoSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!eventoSnapshot.hasData || !eventoSnapshot.data!.exists) {
                    return const SizedBox.shrink(); // Se o evento não for encontrado, não exibe nada
                  }

                  final evento = eventoSnapshot.data!;
                  final nomeEvento = evento['event'] ?? 'Evento desconhecido'; // Usando 'event' no lugar de 'nome'

                  return ExpansionTile(
                    title: Text(nomeEvento),
                    children: convidadosDoEvento.map((convidado) {
                      final nome = convidado['nome'] ?? 'Sem nome';
                      final sobrenome = convidado['sobrenome'] ?? 'Sobrenome desconhecido';
                      final tipoConvidado = convidado['tipoConvidado'] ?? 'Não especificado';
                      final genero = convidado['genero'] ?? 'Não especificado';
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
                    }).toList(),
                  );
                },
              );
            }).toList(),
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
            setState(() {}); // Atualiza a lista após adicionar um convidado
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
