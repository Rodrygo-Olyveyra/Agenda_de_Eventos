import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'telaeventos.dart';

class TelaConvidados extends StatefulWidget {
  const TelaConvidados({super.key});

  @override
  State<TelaConvidados> createState() => _TelaConvidadosState();
}

class _TelaConvidadosState extends State<TelaConvidados> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController notaController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();

  String tipoConvidado = 'Adulto';
  String genero = 'Outro';
  String? eventoSelecionado;

  Future<void> _adicionarConvidado() async {
    final nome = nomeController.text;
    final sobrenome = sobrenomeController.text;
    final nota = notaController.text;
    final telefone = telefoneController.text;
    final email = emailController.text;
    final endereco = enderecoController.text;

    if (eventoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É obrigatório selecionar um evento!')),
      );
      return;
    }

    if (nome.isNotEmpty && sobrenome.isNotEmpty && nota.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('convidados').add({
          'nome': nome,
          'sobrenome': sobrenome,
          'nota': nota,
          'tipoConvidado': tipoConvidado,
          'genero': genero,
          'telefone': telefone,
          'email': email,
          'endereco': endereco,
          'eventoId': eventoSelecionado,
          'criadoEm': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convidado adicionado com sucesso!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaConvidados()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar convidado: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
    }
  }

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
              TextField(
                controller: notaController,
                decoration: const InputDecoration(
                  labelText: 'Nota',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _buildTipoConvidadoSelector(),
              const SizedBox(height: 20),
              _buildGeneroSelector(),
              const SizedBox(height: 20),
              TextField(
                controller: telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Evento'),
                subtitle: Text(eventoSelecionado != null
                    ? 'Evento selecionado'
                    : 'Nenhum evento selecionado'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final evento = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaSelecaoEvento(),
                    ),
                  );
                  setState(() {
                    eventoSelecionado = evento;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _adicionarConvidado,
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
