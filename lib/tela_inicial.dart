import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'tela_calendario.dart';
import 'tela_lista_fornecedores.dart';
import 'tela_lista_orcamento.dart';
import 'tela_lista_convidados.dart';
import 'tela_de_login.dart';

class TelaInicialPersonalizada extends StatefulWidget {
  const TelaInicialPersonalizada({super.key});

  @override
  _TelaInicialPersonalizadaState createState() => _TelaInicialPersonalizadaState();
}

class _TelaInicialPersonalizadaState extends State<TelaInicialPersonalizada> {
  late Map<DateTime, List<Map<String, String>>> _events;
  late CollectionReference eventsCollection;
  late User? user;

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
      // Removendo do Firestore
      await eventsCollection.doc(eventId).delete();

      // Removendo da interface
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

  Map<String, List<Map<String, String>>> _groupEventsByMonth() {
    Map<String, List<Map<String, String>>> groupedEvents = {};

    _events.forEach((date, eventList) {
      String monthYearKey = DateFormat('MMMM - yyyy', 'pt_BR').format(date);
      if (groupedEvents[monthYearKey] == null) {
        groupedEvents[monthYearKey] = [];
      }
      groupedEvents[monthYearKey]!.addAll(eventList);
    });

    groupedEvents.removeWhere((key, value) => value.isEmpty);

    return groupedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicial'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF32CD99),
              ),
              child: Column(
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bem-vindo, Usuário!',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Calendário'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaCalendario()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lista de Eventos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaListaEventos(
                      events: _events,
                      deleteEventCallback: _deleteEvent,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                _confirmarLogout(context);
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ContadorItem(label: 'Dias', value: '00'),
                        ContadorItem(label: 'Horas', value: '00'),
                        ContadorItem(label: 'Min.', value: '00'),
                        ContadorItem(label: 'Seg.', value: '00'),
                      ],
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.event, size: 40),
                      title: Text(
                        'O nome não está definido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('A data não está definida, Seu evento'),
                      trailing: Icon(Icons.menu),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MENU',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuItem(
                    icon: Icons.people,
                    label: 'Convidados',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaListaConvidados()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.attach_money,
                    label: 'Orçamento',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaListaOrcamento()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.business,
                    label: 'Fornecedores',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaListaFornecedores()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Você tem certeza de que deseja sair?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaLogin()),
                );
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
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
            radius: 30,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class TelaListaEventos extends StatelessWidget {
  final Map<DateTime, List<Map<String, String>>> events;
  final Future<void> Function(String, DateTime, Map<String, String>) deleteEventCallback;

  const TelaListaEventos({
    super.key,
    required this.events,
    required this.deleteEventCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Eventos'),
        backgroundColor: Colors.blueGrey,
      ),
      body: events.isEmpty
          ? const Center(
              child: Text(
                'Não há eventos cadastrados.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                DateTime eventDate = events.keys.elementAt(index);
                List<Map<String, String>> eventList = events[eventDate]!;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.blueGrey, width: 1),
                  ),
                  elevation: 4,
                  child: ExpansionTile(
                    title: Text(
                      DateFormat('MMMM yyyy', 'pt_BR').format(eventDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.blueGrey,
                    ),
                    children: eventList.map((event) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.blueGrey, width: 0.5),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          title: Text(
                            event['event'] ?? 'Evento sem nome',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hora: ${event['time']}'),
                              const SizedBox(height: 4),
                              Text(
                                'Descrição: ${event['description']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              deleteEventCallback(event['id']!, eventDate, event);
                            },
                          ),
                          onTap: () {
                            // Aqui pode adicionar ação para ver mais detalhes
                          },
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

class ContadorItem extends StatelessWidget {
  final String label;
  final String value;

  const ContadorItem({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
