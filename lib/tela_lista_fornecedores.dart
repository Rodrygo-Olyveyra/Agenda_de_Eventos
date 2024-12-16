import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_fornecedores.dart';

class TelaListaFornecedores extends StatefulWidget {
  const TelaListaFornecedores({super.key});

  @override
  _TelaListaFornecedoresState createState() => _TelaListaFornecedoresState();
}

class _TelaListaFornecedoresState extends State<TelaListaFornecedores> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fornecedores',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fornecedores')
            .orderBy('criadoEm', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar os fornecedores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum fornecedor adicionado ainda!\nClique no botão abaixo para começar.',
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

          Map<String, List<DocumentSnapshot>> fornecedoresPorEvento = {};

          for (var fornecedor in fornecedores) {
            final eventoId = fornecedor['evento'];

            if (eventoId == null || eventoId.isEmpty) {
              continue;
            }

            if (!fornecedoresPorEvento.containsKey(eventoId)) {
              fornecedoresPorEvento[eventoId] = [];
            }

            fornecedoresPorEvento[eventoId]!.add(fornecedor);
          }

          return ListView(
            children: fornecedoresPorEvento.entries.map((entry) {
              final eventoId = entry.key;
              final fornecedoresDoEvento = entry.value;

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
                      tilePadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        nomeEvento,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      children: fornecedoresDoEvento.map((fornecedor) {
                        final nome = fornecedor['nome'] ?? 'Sem nome';
                        final nota = fornecedor['nota'] ?? 'Sem nota';
                        final telefone = fornecedor['telefone'] ?? 'Sem telefone';
                        final email = fornecedor['email'] ?? 'Sem e-mail';
                        final site = fornecedor['site'] ?? 'Sem site';
                        final endereco = fornecedor['endereco'] ?? 'Sem endereço';
                        final montante = fornecedor['montante'] ?? 0.0;

                        final montanteFormatado = montante is num
                            ? '\$${montante.toStringAsFixed(2)}'
                            : '\$0.00';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            child: Text(
                              nome.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            nome,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                              'Nota: $nota\nTelefone: $telefone\nE-mail: $email'),
                          trailing: Text(
                            montanteFormatado,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
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
                                    Text('Telefone: $telefone'),
                                    Text('E-mail: $email'),
                                    Text('Site: $site'),
                                    Text('Endereço: $endereco'),
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
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaFornecedor()),
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
