import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_prova/tela_inicial.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'tela_de_login.dart';
import 'tela_sobreapp.dart';

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
          "event": doc['event'],
          "time": doc['time'],
          "description": doc['description'],
          "docId": doc.id,
        });
      }
      setState(() {});
    } catch (e) {
      print('Erro ao carregar eventos: $e');
    }
  }


  void _showDeleteConfirmationDialog(
      BuildContext context, Map<String, String> event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              const Text('Você tem certeza que deseja excluir este evento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _deleteEvent(event);
                Navigator.pop(context); 
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

Future<void> _deleteEvent(Map<String, String> event) async {
  try {
    final snapshot = await eventsCollection
        .where('userId', isEqualTo: user?.uid)
        .where('event', isEqualTo: event['event'])
        .where('time', isEqualTo: event['time'])
        .where('description', isEqualTo: event['description'])
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {
      _events.forEach((date, eventList) {
        eventList.removeWhere((e) =>
            e['event'] == event['event'] &&
            e['time'] == event['time'] &&
            e['description'] == event['description']);
        if (eventList.isEmpty) {
          _events.remove(date);
        }
      });
    });


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Evento "${event['event']}" excluído com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('Erro ao excluir evento: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao excluir o evento.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
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
        title: const Text('Calendário Eventsy'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: <Widget>[
      UserAccountsDrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 0, 0, 0)],
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
          child: Icon(Icons.event, size: 40, color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.home, color: Color.fromARGB(255, 0, 0, 0)),
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
        leading: const Icon(Icons.event_note, color: Color.fromARGB(255, 0, 0, 0)),
        title: const Text('Lista de Eventos', style: TextStyle(fontSize: 18)),
        onTap: () async {
          Navigator.pop(context);
         await Navigator.push(
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
        leading: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 0, 0, 0)),
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
  leading: const Icon(Icons.info_outline, color: Color.fromARGB(157, 25, 0, 255)),
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
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
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
            locale: 'pt_BR', 
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _showAddEventDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 161, 241),
            ),
            child: const Text('Adicionar Evento'),
          ),
          const SizedBox(height: 20),
          if (_events[_selectedDay] != null &&
              _events[_selectedDay]!.isNotEmpty)
            Column(
              children: _events[_selectedDay]!.map((event) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(event['event'] ?? 'Evento sem nome'),
                    subtitle: Text(
                        'Hora: ${event['time']}\nDescrição: ${event['description']}'),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
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
      String eventId = event['docId'] ?? '';

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
        title: const Text('Sua lista Eventsy'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    childrenPadding: const EdgeInsets.all(8),
                    children: eventList.map((event) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 0.5),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          title: Text(
                            event['event'] ?? 'Evento sem nome',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hora: ${event['time']}',
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                'Descrição: ${event['description']}',
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              bool? confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Excluir Evento'),
                                    content: const Text(
                                        'Você tem certeza de que deseja excluir este evento?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('Excluir',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmDelete == true) {
                                await _deleteEventFromFirebase(event);
                                widget.onDeleteEvent(event);
                                setState(() {
                                  widget.events[eventDate]?.remove(event);
                                  if (widget.events[eventDate]?.isEmpty ?? false) {
                                    widget.events.remove(eventDate);
                                  }
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Evento excluído com sucesso!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                          onTap: () {},
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