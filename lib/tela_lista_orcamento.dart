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
        title: const Text('Orçamentos'),
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

          // Agrupar orçamentos por eventoId
          Map<String, List<DocumentSnapshot>> orcamentosPorEvento = {};

          for (var orcamento in orcamentos) {
            final eventoId = orcamento['eventoId']; // Certifique-se que o campo eventoId existe

            if (eventoId == null || eventoId.isEmpty) {
              continue; // Ignorar orçamentos sem eventoId
            }

            if (!orcamentosPorEvento.containsKey(eventoId)) {
              orcamentosPorEvento[eventoId] = [];
            }

            orcamentosPorEvento[eventoId]!.add(orcamento);
          }

          // Exibir orçamentos agrupados por evento
          return ListView(
            children: orcamentosPorEvento.entries.map((entry) {
              final eventoId = entry.key;
              final orcamentosDoEvento = entry.value;

              // Buscar o evento para obter o nome
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('events').doc(eventoId).get(),
                builder: (context, eventoSnapshot) {
                  if (eventoSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!eventoSnapshot.hasData || !eventoSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final evento = eventoSnapshot.data!;
                  final nomeEvento = evento['event'] ?? 'Evento desconhecido';

                  return ExpansionTile(
                    title: Text(nomeEvento),
                    children: orcamentosDoEvento.map((orcamento) {
                      final nome = orcamento['nome'] ?? 'Nome não especificado';
                      final categoria = orcamento['categoria'] ?? 'Categoria não especificada';
                      final montante = orcamento['montante'] ?? 0.0;
                      final nota = orcamento['nota'] ?? 'Sem nota';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(nome),
                          subtitle: Text('Categoria: $categoria\nMontante: \$${montante.toStringAsFixed(2)}\nNota: $nota'),
                          trailing: const Icon(Icons.money),
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
                                    Text('Montante: \$${montante.toStringAsFixed(2)}'),
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
            MaterialPageRoute(builder: (context) => const TelaOrcamento()),
          );

          if (resultado == true) {
            setState(() {}); // Atualiza a lista após adicionar um orçamento
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
