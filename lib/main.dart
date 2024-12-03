import 'package:flutter/material.dart';
import 'tela_login.dart'; // Importando a tela de login

void main() {
  runApp(SimplesAgendaApp());
}

class SimplesAgendaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simples Agenda',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const TelaLogin(), // Chamando a tela de login
    );
  }
}
