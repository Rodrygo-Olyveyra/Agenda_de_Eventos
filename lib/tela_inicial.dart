import 'package:flutter/material.dart';
import 'package:flutter_application_prova/tela_calendario.dart';
import 'tela_lista_fornecedores.dart';
import 'tela_lista_orcamento.dart';
import 'tela_lista_convidados.dart';

class TelaInicialPersonalizada extends StatelessWidget {
  const TelaInicialPersonalizada({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicial'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF32CD99),
              ),
              child: Column(
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bem-vindo, Usuário!',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Calendário'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaCalendario()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                // Lógica de saída
                Navigator.pop(context); // Fecha o drawer
                // Pode adicionar a lógica de logout aqui
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contagem regressiva e informações do evento
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ContadorItem(label: 'Dias', value: '00'),
                        ContadorItem(label: 'Horas', value: '00'),
                        ContadorItem(label: 'Min.', value: '00'),
                        ContadorItem(label: 'Seg.', value: '00'),
                      ],
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.event, size: 40),
                      title: Text(
                        'O nome não está definido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('A data não está definida, Seu evento'),
                      trailing: Icon(Icons.menu),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Menu
            const Text(
              'MENU',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuItem(
                    icon: Icons.people,
                    label: 'Convidados',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaListaConvidados()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.attach_money,
                    label: 'Orçamento',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaListaOrcamento()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.business,
                    label: 'Fornecedores',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaListaFornecedores()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class ContadorItem extends StatelessWidget {
  final String label;
  final String value;

  const ContadorItem({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
