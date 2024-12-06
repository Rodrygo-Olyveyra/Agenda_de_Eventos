import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_prova/tela_de_login.dart';
import 'package:intl/intl.dart'; 
import 'package:table_calendar/table_calendar.dart';

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
    // Verifica se o usuário está autenticado
    if (user == null) {
      print('Usuário não autenticado!');
      return;
    }

    try {
      final snapshot = await eventsCollection
          .where('userId', isEqualTo: user?.uid)
          .get();

      // Verificando se a consulta retornou documentos
      if (snapshot.docs.isEmpty) {
        print('Nenhum evento encontrado!');
      }

      for (var doc in snapshot.docs) {
        DateTime eventDate = DateTime.parse(doc['date']);
        if (_events[eventDate] == null) {
          _events[eventDate] = [];
        }
        _events[eventDate]!.add({
          "event": doc['event'],
          "time": doc['time'],
          "description": doc['description'], // Adicionando descrição
        });
      }
      setState(() {});
    } catch (e) {
      print('Erro ao carregar eventos: $e');
    }
  }

  void _addEvent(String event, String time, String description) async {
    await eventsCollection.add({
      'userId': user?.uid,
      'date': _selectedDay.toIso8601String(),
      'event': event,
      'time': time,
      'description': description, // Adicionando descrição
    });

    setState(() {
      if (_events[_selectedDay] == null) {
        _events[_selectedDay] = [];
      }
      _events[_selectedDay]!.add({"event": event, "time": time, "description": description});
    });
  }

  // Mostra o diálogo para adicionar evento
  void _showAddEventDialog(BuildContext context) {
    TextEditingController eventController = TextEditingController();
    TextEditingController descriptionController = TextEditingController(); // Controller para descrição
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
                  // Campo de texto para o evento
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
                  // Campo de texto para a descrição
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLines: 3,  // Definindo um limite de linhas para a descrição
                  ),
                  const SizedBox(height: 16),
                  // Seletor de horário
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
                        descriptionController.text, // Passando a descrição
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Calendário'),
              onTap: () {
                Navigator.pop(context);
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
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _showAddEventDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'ADICIONAR EVENTO',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class TelaListaEventos extends StatelessWidget {
  final Map<DateTime, List<Map<String, String>>> events;

  const TelaListaEventos({super.key, required this.events});

  // Função para agrupar eventos por mês e ano
  Map<String, List<Map<String, String>>> _groupEventsByMonth() {
    Map<String, List<Map<String, String>>> groupedEvents = {};

    events.forEach((date, eventList) {
      // Formatando a chave para "Mês - Ano"
      String monthYearKey = DateFormat('MMMM - yyyy').format(date);  // Exemplo: Dezembro - 2024
      if (groupedEvents[monthYearKey] == null) {
        groupedEvents[monthYearKey] = [];
      }
      groupedEvents[monthYearKey]!.addAll(eventList);
    });

    return groupedEvents;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, String>>> groupedEvents = _groupEventsByMonth();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Eventos'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        children: groupedEvents.entries.map((entry) {
          String monthYear = entry.key;  // Ex: Dezembro - 2024
          List<Map<String, String>> eventsList = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  // Título do mês
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      monthYear, // Exibe o mês e ano no formato desejado
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Lista de eventos
                  Column(
                    children: eventsList.map((event) {
                      return InkWell(
                        onTap: () {
                          // Ação ao clicar no evento (detalhamento)
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(event["event"]!),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Horário: ${event["time"]}'),
                                    SizedBox(height: 8),
                                    Text('Descrição: ${event["description"]}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Fechar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 3.0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Ícone representativo do evento
                                Icon(
                                  Icons.event_note,
                                  color: Colors.blueGrey,
                                  size: 32.0,
                                ),
                                const SizedBox(width: 16),
                                // Informações do evento
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event["event"]!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Horário: ${event["time"]}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event["description"]!,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
