import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tela_orçamento.dart';

class TelaListaOrcamentos extends StatefulWidget {
  const TelaListaOrcamentos({super.key});

  @override
  _TelaListaOrcamentosState createState() => _TelaListaOrcamentosState();
}

class _TelaListaOrcamentosState extends State<TelaListaOrcamentos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orçamentos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum orçamento adicionado ainda!\nClique no botão abaixo para começar.',
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

          Map<String, List<DocumentSnapshot>> orcamentosPorEvento = {};

          for (var orcamento in orcamentos) {
            final eventoId = orcamento['eventoId'];

            if (eventoId == null || eventoId.isEmpty) {
              continue;
            }

            if (!orcamentosPorEvento.containsKey(eventoId)) {
              orcamentosPorEvento[eventoId] = [];
            }

            orcamentosPorEvento[eventoId]!.add(orcamento);
          }

          return ListView(
            children: orcamentosPorEvento.entries.map((entry) {
              final eventoId = entry.key;
              final orcamentosDoEvento = entry.value;

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
                      children: orcamentosDoEvento.map((orcamento) {
                        final nome = orcamento['nome'] ?? 'Sem nome';
                        final categoria =
                            orcamento['categoria'] ?? 'Categoria não especificada';
                        final montante = orcamento['montante'] ?? 0.0;
                        final nota = orcamento['nota'] ?? 'Sem nota';

                        final montanteFormatado = montante is num
                            ? 'R\$ ${montante.toStringAsFixed(2)}'
                            : 'R\$ 0.00';

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
                              'Categoria: $categoria\nMontante: $montanteFormatado\nNota: $nota'),
                          trailing: const Icon(Icons.attach_money, color: Colors.green),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(nome),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Categoria: $categoria'),
                                    Text('Montante: $montanteFormatado'),
                                    Text('Nota: $nota'),
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
            MaterialPageRoute(builder: (context) => const TelaOrcamento()),
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
