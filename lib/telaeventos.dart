import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaSelecaoEvento extends StatefulWidget {
  const TelaSelecaoEvento({super.key});

  @override
  State<TelaSelecaoEvento> createState() => _TelaSelecaoEventoState();
}

class _TelaSelecaoEventoState extends State<TelaSelecaoEvento> {
  String? eventoSelecionado;

  Future<List<DocumentSnapshot>> _buscarEventos() async {
    final eventosRef = FirebaseFirestore.instance.collection('events');

    try {
      final querySnapshot = await eventosRef.get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Nenhum evento encontrado.');
      } else {
        debugPrint('Eventos encontrados: ${querySnapshot.docs.length}');
      }

      return querySnapshot.docs;
    } catch (e) {
      debugPrint('Erro ao buscar eventos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Escolher Evento',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _buscarEventos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar eventos.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum evento encontrado.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          }
          final eventos = snapshot.data!;
          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              final nomeEvento = evento['event'] ?? 'Sem nome';
              final dataEvento = evento['date'] ?? 'Sem data';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    nomeEvento,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  subtitle: Text('Data: $dataEvento'),
                  trailing: const Icon(Icons.event, color: Colors.teal),
                  onTap: () {
                    setState(() {
                      eventoSelecionado = evento.id;
                    });
                    Navigator.pop(context, eventoSelecionado);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
