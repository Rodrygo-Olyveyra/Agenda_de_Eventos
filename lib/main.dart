import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'tela_de_login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SimplesAgendaApp());
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
      home: const TelaLogin(),
      supportedLocales: const [
        Locale('en', 'US'), // Inglês
        Locale('pt', 'BR'), // Português
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('pt', 'BR'), // Define o idioma padrão como português
    );
  }
}
