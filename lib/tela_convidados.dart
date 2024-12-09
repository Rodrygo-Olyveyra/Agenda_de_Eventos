import 'package:flutter/material.dart';

class TelaConvidados extends StatefulWidget {
  const TelaConvidados({super.key});

  @override
  State<TelaConvidados> createState() => _TelaConvidadosState();
}

class _TelaConvidadosState extends State<TelaConvidados> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

  String tipoConvidado = 'Adulto';
  String genero = 'Outro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicione um convidado novo'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome e Sobrenome
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: sobrenomeController,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nota
              TextField(
                controller: notaController,
                decoration: const InputDecoration(
                  labelText: 'Nota',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Tipo de Convidado (Adulto, Criança, Bebê) - Segmented Buttons
              _buildTipoConvidadoSelector(),
              const SizedBox(height: 20),

              // Gênero (Masculino, Feminino, Outro) - Segmented Buttons
              _buildGeneroSelector(),
              const SizedBox(height: 20),

              // Telefone, Email e Endereço
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Botão Adicionar Convidado
              ElevatedButton(
                onPressed: () {
                  // Lógica para adicionar o convidado
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('ADICIONAR CONVIDADO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Selector de Tipo de Convidado (Adulto, Criança, Bebê)
  Widget _buildTipoConvidadoSelector() {
    return ToggleButtons(
      isSelected: [
        tipoConvidado == 'Adulto',
        tipoConvidado == 'Criança',
        tipoConvidado == 'Bebê',
      ],
      onPressed: (int index) {
        setState(() {
          if (index == 0) tipoConvidado = 'Adulto';
          if (index == 1) tipoConvidado = 'Criança';
          if (index == 2) tipoConvidado = 'Bebê';
        });
      },
      color: Colors.grey,
      selectedColor: Colors.white,
      selectedBorderColor: Colors.orange,
      borderRadius: BorderRadius.circular(8),
      fillColor: Colors.orange,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Adulto'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Criança'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Bebê'),
        ),
      ],
    );
  }

  // Selector de Gênero (Masculino, Feminino, Outro)
  Widget _buildGeneroSelector() {
    return ToggleButtons(
      isSelected: [
        genero == 'Masculino',
        genero == 'Feminino',
        genero == 'Outro',
      ],
      onPressed: (int index) {
        setState(() {
          if (index == 0) genero = 'Masculino';
          if (index == 1) genero = 'Feminino';
          if (index == 2) genero = 'Outro';
        });
      },
      color: Colors.grey,
      selectedColor: Colors.white,
      selectedBorderColor: Colors.orange,
      borderRadius: BorderRadius.circular(8),
      fillColor: Colors.orange,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Masculino'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Feminino'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Outro'),
        ),
      ],
    );
  }
}
