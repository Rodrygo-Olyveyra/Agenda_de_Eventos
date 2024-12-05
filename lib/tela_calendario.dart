import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class TelaCalendario extends StatefulWidget {
  const TelaCalendario({Key? key}) : super(key: key);

  @override
  _TelaCalendarioState createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  late Map<DateTime, List<Map<String, String>>> _events;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late User? user;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    user = FirebaseAuth.instance.currentUser;
    _loadEventsForAllDays(); // Carrega todos os eventos agendados para qualquer dia
  }

  // Carrega todos os eventos do Firebase para todos os dias relevantes
  void _loadEventsForAllDays() async {
    QuerySnapshot querySnapshot = await _firestore.collection('events').get();
    for (var doc in querySnapshot.docs) {
      DateTime eventDate = (doc['date'] as Timestamp).toDate();

      // Adiciona o evento ao mapa de eventos para o dia correspondente
      if (_events[eventDate] == null) {
        _events[eventDate] = [];
      }
      _events[eventDate]?.add({
        "event": doc['event'],
        "description": doc['description'],
        "time": doc['time'],
      });
    }
    setState(() {}); // Atualiza o estado após carregar os eventos
  }

  // Adiciona um evento ao Firestore e ao calendário
  void _addEvent(String event, String description, String time) async {
    DateTime eventDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      int.parse(time.split(":")[0]),
      int.parse(time.split(":")[1]),
    );

    // Salva o evento no Firebase
    Map<String, dynamic> eventData = {
      'event': event,
      'description': description,
      'time': time,
      'date': Timestamp.fromDate(eventDate),
      'createdBy': user?.displayName ?? 'Anônimo',
    };

    await _firestore.collection('events').add(eventData);

    // Atualiza a lista de eventos no app
    setState(() {
      if (_events[_selectedDay] == null) {
        _events[_selectedDay] = [];
      }
      _events[_selectedDay]!.add({
        "event": event,
        "description": description,
        "time": time,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        backgroundColor: Colors.blueGrey,
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
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController _eventController = TextEditingController();
                  TextEditingController _descriptionController = TextEditingController();
                  TextEditingController _timeController = TextEditingController();
                  return AlertDialog(
                    title: const Text('Adicionar Evento'),
                    content: Container(
                      height: 280,
                      child: Column(
                        children: [
                          TextField(
                            controller: _eventController,
                            decoration: const InputDecoration(labelText: 'Nome do Evento'),
                          ),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(labelText: 'Descrição'),
                          ),
                          TextField(
                            controller: _timeController,
                            decoration: const InputDecoration(labelText: 'Horário (HH:mm)'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (_eventController.text.isNotEmpty &&
                              _descriptionController.text.isNotEmpty &&
                              _timeController.text.isNotEmpty) {
                            _addEvent(
                              _eventController.text,
                              _descriptionController.text,
                              _timeController.text,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Adicionar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('ADICIONAR EVENTO'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: _events[_selectedDay]?.map((event) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${event["event"]} - ${event["time"]}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Descrição: ${event["description"]}'),
                  ),
                );
              }).toList() ??
                  [const Center(child: Text('Nenhum evento registrado para esta data.'))],
            ),
          ),
        ],
      ),
    );
  }
}
