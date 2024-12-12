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
      // Realizando a consulta
      final querySnapshot = await eventosRef.get();
      
      // Verificando se retornou documentos
      if (querySnapshot.docs.isEmpty) {
        print('Nenhum evento encontrado.');
      } else {
        print('Eventos encontrados: ${querySnapshot.docs.length}');
      }

      return querySnapshot.docs;
    } catch (e) {
      print('Erro ao buscar eventos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher Evento'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _buscarEventos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum evento encontrado.'));
          }

          final eventos = snapshot.data!;

          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              final eventName = evento['event'] ?? 'Sem nome';
              final eventDate = evento['date'] ?? 'Sem data';

              return ListTile(
                title: Text(eventName),
                subtitle: Text('Data: $eventDate'),
                onTap: () {
                  setState(() {
                    eventoSelecionado = evento.id; // Seleciona o ID do evento
                  });
                  Navigator.pop(context, eventoSelecionado); // Retorna o ID do evento
                },
              );
            },
          );
        },
      ),
    );
  }
}
