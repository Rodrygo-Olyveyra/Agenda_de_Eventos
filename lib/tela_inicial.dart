import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'tela_calendario.dart';
import 'tela_lista_fornecedores.dart';
import 'tela_lista_orcamento.dart';
import 'tela_lista_convidados.dart';
import 'tela_de_login.dart';
import 'tela_sobreapp.dart';

class TelaInicialPersonalizada extends StatefulWidget {
  const TelaInicialPersonalizada({super.key});

  @override
  _TelaInicialPersonalizadaState createState() =>
      _TelaInicialPersonalizadaState();
}

class _TelaInicialPersonalizadaState extends State<TelaInicialPersonalizada> {
  late Map<DateTime, List<Map<String, String>>> _events;
  late CollectionReference eventsCollection;
  late User? user;

  final Color primaryColor = const Color(0xFF32CD99);
  final Color secondaryColor = const Color(0xFF20B2AA);
  final Color backgroundColor = const Color(0xFFF8F8F8);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _events = {};
    user = FirebaseAuth.instance.currentUser;
    eventsCollection = FirebaseFirestore.instance.collection('events');
    _loadEvents();
  }

  void _loadEvents() async {
    if (user == null) {
      print('Usuário não autenticado!');
      return;
    }

    try {
      final snapshot = await eventsCollection.get();
      for (var doc in snapshot.docs) {
        DateTime eventDate = DateTime.parse(doc['date']);
        if (_events[eventDate] == null) {
          _events[eventDate] = [];
        }
        _events[eventDate]!.add({
          "id": doc.id,
          "event": doc['event'],
          "time": doc['time'],
          "description": doc['description'],
        });
      }
      setState(() {});
    } catch (e) {
      print('Erro ao carregar eventos: $e');
    }
  }

  Future<void> _deleteEvent(String eventId, DateTime eventDate, Map<String, String> event) async {
    try {
      await eventsCollection.doc(eventId).delete();

      setState(() {
        _events[eventDate]?.remove(event);
        if (_events[eventDate]?.isEmpty ?? true) {
          _events.remove(eventDate);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento excluído com sucesso!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Erro ao excluir evento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir o evento.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Eventsy: Agenda de Eventos'),
        centerTitle: true,
        backgroundColor: primaryColor, 
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: const Text(
                'Bem-vindo ao Eventsy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? 'Sem e-mail cadastrado',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.event, size: 40, color: Color(0xFF32CD99)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.teal),
              title: const Text('Início', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaInicialPersonalizada()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note, color: Colors.teal),
              title: const Text('Lista de Eventos', style: TextStyle(fontSize: 18)),
              onTap: ()  {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaListaEventos(
                      events: _events,
                      onDeleteEvent: (event) {
                        setState(() {
                          _events[event['date']]?.remove(event);
                          if (_events[event['date']]?.isEmpty == true) {
                            _events.remove(event['date']);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.teal),
              title: const Text('Calendário', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaCalendario()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(fontSize: 18)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaLogin()),
                );
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Outras opções',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.teal),
              title: const Text('Sobre o App', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaSobreApp()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Card(
                elevation: 4,
                color: cardColor, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Organize seus eventos de forma simples e eficiente.',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'O que você gostaria de fazer?',
                        style: TextStyle(fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'MENU',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,  // Diminui o espaço entre as linhas
                  crossAxisSpacing: 8,  // Diminui o espaço entre as colunas
                  children: [
                    _buildMenuItem(
                      icon: Icons.people,
                      label: 'Convidados',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TelaListaConvidados()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.attach_money,
                      label: 'Orçamento',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TelaListaOrcamentos()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.business,
                      label: 'Fornecedores',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TelaListaFornecedores()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.business,
                      label: 'Adicionar Eventos ',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TelaCalendario()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return scaffold;
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25, // Tamanho do ícone foi reduzido
            backgroundColor: primaryColor, 
            child: Icon(icon, size: 28, color: Colors.white), // Ícone menor
          ),
          const SizedBox(height: 4),  // Reduzindo o espaço entre ícone e texto
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),  // Tamanho da fonte reduzido
          ),
        ],
      ),
    );
  }
}

class TelaListaEventos extends StatefulWidget {
  final Map<DateTime, List<Map<String, String>>> events;
  final Function(Map<String, String>) onDeleteEvent;

  const TelaListaEventos({
    super.key,
    required this.events,
    required this.onDeleteEvent,
  });

  @override
  _TelaListaEventosState createState() => _TelaListaEventosState();
}

class _TelaListaEventosState extends State<TelaListaEventos> {
  Future<void> _deleteEventFromFirebase(Map<String, String> event) async {
    try {
      String eventId = event['id'] ?? '';

      if (eventId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .delete();
        print("Evento excluído com sucesso.");
      } else {
        print("ID do evento não encontrado.");
      }
    } catch (e) {
      print("Erro ao excluir evento do Firebase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> sortedEventDates = widget.events.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sua Lista Eventsy'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
        elevation: 4,
      ),
      body: widget.events.isEmpty
          ? const Center(
              child: Text(
                'Não há eventos cadastrados.',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            )
          : ListView.builder(
              itemCount: sortedEventDates.length,
              itemBuilder: (context, index) {
                DateTime eventDate = sortedEventDates[index];
                List<Map<String, String>> eventList = widget.events[eventDate]!;

                String formattedDate =
                    DateFormat('d MMMM yyyy', 'pt_BR').format(eventDate);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black26,
                  child: ExpansionTile(
                    title: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal,
                      ),
                    ),
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.teal,
                    ),
                    childrenPadding: const EdgeInsets.all(8),
                    children: eventList.map((event) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.teal, width: 0.5),
                        ),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            event['event']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hora: ${event['time']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Descrição: ${event['description']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              widget.onDeleteEvent(event);
                              _deleteEventFromFirebase(event);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
