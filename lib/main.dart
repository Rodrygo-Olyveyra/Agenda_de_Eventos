import 'package:flutter/material.dart';
import 'tela_cadastro.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SimplesAgendaApp());
}

class SimplesAgendaApp extends StatelessWidget {
  const SimplesAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simples Agenda',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const TelaCadastro(), 
    );
  }
}
