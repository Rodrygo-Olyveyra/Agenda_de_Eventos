import 'package:flutter/material.dart';

class TelaCategoria extends StatefulWidget {
  const TelaCategoria({super.key});

  @override
  State<TelaCategoria> createState() => _TelaCategoriaState();
}

class _TelaCategoriaState extends State<TelaCategoria> {
  final List<String> categorias = [
    'Categoria não atribuída',
    'Traje & Acessórios',
    'Saúde & Beleza',
    'Música & Show',
    'Flores & Decoração',
    'Foto & Vídeo',
    'Acessórios',
    'Banquete',
    'Transporte',
    'Alojamento',
  ];

  String categoriaSelecionada = 'Categoria não atribuída'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categoria'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, categoriaSelecionada),
        ),
      ),
      body: ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          return ListTile(
            leading: const Icon(Icons.label),
            title: Text(categoria),
            trailing: Icon(
              categoria == categoriaSelecionada
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: categoria == categoriaSelecionada
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            onTap: () {
              setState(() {
                categoriaSelecionada = categoria; 
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
