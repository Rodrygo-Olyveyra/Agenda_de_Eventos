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
        title: const Text('Convidados',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
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
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum convidado adicionado ainda!\nClique no botão abaixo para começar.',
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

          Map<String, List<DocumentSnapshot>> convidadosPorEvento = {};

          for (var convidado in convidados) {
            final eventoId = convidado['eventoId'];

            if (eventoId == null) {
              continue;
            }

            if (!convidadosPorEvento.containsKey(eventoId)) {
              convidadosPorEvento[eventoId] = [];
            }

            convidadosPorEvento[eventoId]!.add(convidado);
          }

          return ListView(
            children: convidadosPorEvento.entries.map((entry) {
              final eventoId = entry.key;
              final convidadosDoEvento = entry.value;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('events')
                    .doc(eventoId)
                    .get(),
                builder: (context, eventoSnapshot) {
                  if (eventoSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  if (!eventoSnapshot.hasData || !eventoSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final evento = eventoSnapshot.data!;
                  final nomeEvento = evento['event'] ?? 'Evento desconhecido';

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        nomeEvento,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      children: convidadosDoEvento.map((convidado) {
                        final nome = convidado['nome'] ?? 'Sem nome';
                        final sobrenome = convidado['sobrenome'] ?? '';
                        final tipoConvidado = convidado['tipoConvidado'] ?? 'Não especificado';
                        final genero = convidado['genero'] ?? 'Não especificado';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text(
                              nome.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text('$nome $sobrenome',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          subtitle: Text('$tipoConvidado - $genero'),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.teal),
                            onPressed: () {
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
                                      Text('Telefone: ${convidado['telefone'] ?? 'Não informado'}'),
                                      Text('Email: ${convidado['email'] ?? 'Não informado'}'),
                                      Text('Endereço: ${convidado['endereco'] ?? 'Não informado'}'),
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
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaConvidados()),
          );

          if (resultado == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
