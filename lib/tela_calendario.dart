import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TelaCalendario extends StatefulWidget {
  const TelaCalendario({super.key});

  @override
  _TelaCalendarioState createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final Map<DateTime, List<Map<String, String>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }
  void _addEvent(String name, String description, String time) {
    if (_events[_selectedDay] == null) {
      _events[_selectedDay] = [];
    }
    setState(() {
      _events[_selectedDay]?.add({
        'name': name,
        'description': description,
        'time': time,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário de Eventos'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 01, 01),
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
                  TextEditingController _nameController = TextEditingController();
                  TextEditingController _descriptionController = TextEditingController();
                  TextEditingController _timeController = TextEditingController();

                  return AlertDialog(
                    title: const Text('Adicionar Evento'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: 'Nome do evento'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(hintText: 'Descrição do evento'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _timeController,
                          decoration: const InputDecoration(hintText: 'Horário do evento (HH:mm)'),
                          keyboardType: TextInputType.datetime,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (_nameController.text.isNotEmpty &&
                              _descriptionController.text.isNotEmpty &&
                              _timeController.text.isNotEmpty) {
                            _addEvent(
                              _nameController.text,
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
                  title: Text(event['name'] ?? 'Sem nome'),
                  subtitle: Text('${event['description'] ?? 'Sem descrição'} - ${event['time'] ?? 'Sem horário'}'),
                );
              }).toList() ?? [],
            ),
          ),
        ],
      ),
    );
  }
}
