import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_prova/tela_inicial.dart'; // Importando a tela inicial
import 'package:intl/intl.dart'; 
import 'package:table_calendar/table_calendar.dart';
import 'tela_de_login.dart';

class TelaCalendario extends StatefulWidget {
  const TelaCalendario({super.key});

  @override
  _TelaCalendarioState createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  late Map<DateTime, List<Map<String, String>>> _events;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late User? user;
  late CollectionReference eventsCollection;

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    user = FirebaseAuth.instance.currentUser;
    eventsCollection = FirebaseFirestore.instance.collection('events');
    _loadEvents();
  }

  // Carrega os eventos do Firestore
  void _loadEvents() async {
    if (user == null) {
      print('Usuário não autenticado!');
      return;
    }

    try {
      // Remova o filtro onde 'userId' é igual ao 'user?.uid'
      final snapshot = await eventsCollection.get();

      for (var doc in snapshot.docs) {
        DateTime eventDate = DateTime.parse(doc['date']);
        if (_events[eventDate] == null) {
          _events[eventDate] = [];
        }
        _events[eventDate]!.add({
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

  // Exibe o diálogo de confirmação para deletar um evento
  void _showDeleteConfirmationDialog(BuildContext context, Map<String, String> event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você tem certeza que deseja excluir este evento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                // Remove o evento do Firestore
                await _deleteEvent(event);
                Navigator.pop(context); // Fecha o diálogo
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  // Deleta o evento do Firestore
  Future<void> _deleteEvent(Map<String, String> event) async {
    try {
      final snapshot = await eventsCollection
          .where('userId', isEqualTo: user?.uid)
          .where('date', isEqualTo: _selectedDay.toIso8601String())
          .where('event', isEqualTo: event['event'])
          .where('time', isEqualTo: event['time'])
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _events[_selectedDay]?.remove(event);
        if (_events[_selectedDay]?.isEmpty ?? false) {
          _events.remove(_selectedDay);
        }
      });
    } catch (e) {
      print('Erro ao excluir evento: $e');
    }
  }

  // Adiciona um evento ao Firestore
  void _addEvent(String event, String time, String description) async {
    await eventsCollection.add({
      'userId': user?.uid,
      'date': _selectedDay.toIso8601String(),
      'event': event,
      'time': time,
      'description': description,
    });

    setState(() {
      if (_events[_selectedDay] == null) {
        _events[_selectedDay] = [];
      }
      _events[_selectedDay]!.add({
        "event": event,
        "time": time,
        "description": description,
      });
    });
  }

  // Mostra o diálogo para adicionar um novo evento
  void _showAddEventDialog(BuildContext context) {
    TextEditingController eventController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              title: const Text(
                'Adicionar Evento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: eventController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Evento',
                      prefixIcon: const Icon(Icons.event),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Horário: ${selectedTime.format(context)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.access_time, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (eventController.text.isNotEmpty) {
                      _addEvent(
                        eventController.text,
                        selectedTime.format(context),
                        descriptionController.text,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        backgroundColor: Colors.blueGrey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF32CD99),
              ),
              child: Column(
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text('Bem-vindo, ${user?.displayName ?? 'Usuário'}!'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaInicialPersonalizada()), // Navegar para a tela inicial
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Calendário'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
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
                    builder: (context) => TelaListaEventos(events: _events),
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmação'),
                      content: const Text('Você tem certeza que deseja sair?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
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
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Exibindo eventos para o dia selecionado
          if (_events[_selectedDay]?.isNotEmpty ?? false)
            Expanded(
              child: ListView.builder(
                itemCount: _events[_selectedDay]?.length ?? 0,
                itemBuilder: (context, index) {
                  var event = _events[_selectedDay]![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Text(event["event"]!),
                      subtitle: Text('${event["time"]!} - ${event["description"]!}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(context, event),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Text('Nenhum evento para este dia.'),
          ElevatedButton(
            onPressed: () => _showAddEventDialog(context),
            child: const Text('Adicionar Evento'),
          ),
        ],
      ),
    );
  }
}

class TelaListaEventos extends StatelessWidget {
  final Map<DateTime, List<Map<String, String>>> events;

  const TelaListaEventos({super.key, required this.events});

  Map<String, List<Map<String, String>>> _groupEventsByMonth() {
    Map<String, List<Map<String, String>>> groupedEvents = {};

    // Agrupar eventos por mês e ano
    events.forEach((date, eventList) {
      String monthYearKey = DateFormat('MMMM - yyyy').format(date);  // Agrupar por mês e ano
      if (groupedEvents[monthYearKey] == null) {
        groupedEvents[monthYearKey] = [];
      }
      groupedEvents[monthYearKey]!.addAll(eventList);  // Adiciona os eventos para o mês
    });

    // Filtra apenas os meses que têm eventos
    groupedEvents.removeWhere((key, value) => value.isEmpty); // Remover meses sem eventos

    return groupedEvents;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, String>>> groupedEvents = _groupEventsByMonth();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos por Mês'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        children: groupedEvents.keys.map((monthYear) {
          return ExpansionTile(
            title: Text(monthYear),
            children: groupedEvents[monthYear]!.map((event) {
              return ListTile(
                title: Text(event["event"]!),
                subtitle: Text(event["description"]!),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
