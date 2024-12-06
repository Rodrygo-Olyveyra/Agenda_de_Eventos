import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_prova/tela_de_login.dart';
import 'package:table_calendar/table_calendar.dart';

class TelaCalendario extends StatefulWidget {
  const TelaCalendario({Key? key}) : super(key: key);

  @override
  _TelaCalendarioState createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  late Map<DateTime, List<Map<String, String>>> _events; // Armazena eventos por dia
  late DateTime _selectedDay; // Dia selecionado
  late DateTime _focusedDay; // Dia focalizado no calendário
  late User? user; // Usuário logado

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    user = FirebaseAuth.instance.currentUser; // Obtém o usuário logado
  }

  /// Adiciona um evento ao dia selecionado
  void _addEvent(String event, String time) {
    setState(() {
      if (_events[_selectedDay] == null) {
        _events[_selectedDay] = [];
      }
      _events[_selectedDay]!.add({"event": event, "time": time});
    });
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
                  MaterialPageRoute(builder: (context) => TelaListaEventos(events: _events)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TelaCalendario()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TelaLogin()),
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
                _selectedDay = selectedDay; // Atualiza a data selecionada
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
                  TextEditingController _timeController = TextEditingController();
                  return AlertDialog(
                    title: const Text('Adicionar Evento'),
                    content: Column(
                      children: [
                        TextField(
                          controller: _eventController,
                          decoration: const InputDecoration(hintText: 'Digite o evento'),
                        ),
                        TextField(
                          controller: _timeController,
                          decoration: const InputDecoration(hintText: 'Digite o horário'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (_eventController.text.isNotEmpty && _timeController.text.isNotEmpty) {
                            _addEvent(_eventController.text, _timeController.text); // Adiciona o evento na data selecionada
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'ADICIONAR EVENTO',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: _events[_selectedDay]?.map((event) {
                return ListTile(
                  title: Text('${event["event"]} - ${event["time"]}'),
                );
              }).toList() ?? [],
            ),
          ),
        ],
      ),
    );
  }
}

class TelaListaEventos extends StatelessWidget {
  final Map<DateTime, List<Map<String, String>>> events;
  
  TelaListaEventos({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> eventList = [];
    events.forEach((date, eventDetails) {
      for (var event in eventDetails) {
        eventList.add(ListTile(
          title: Text('${event["event"]}'),
          subtitle: Text('Data: ${date.toLocal()} - Horário: ${event["time"]}'),
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Eventos'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        children: eventList.isEmpty ? [const Center(child: Text("Nenhum evento registrado."))] : eventList,
      ),
    );
  }
}