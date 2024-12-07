import 'package:flutter/material.dart';

class TelaInicialPersonalizada extends StatelessWidget {
  const TelaInicialPersonalizada({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicial'),
        centerTitle: true,
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
              style: TextStyle(fontWeight: FontWeight.bold),
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
                      // Ação do menu Convidados
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.attach_money,
                    label: 'Orçamento',
                    onTap: () {
                      // Ação do menu Orçamento
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.business,
                    label: 'Fornecedores',
                    onTap: () {
                      // Ação do menu Fornecedores
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
            child: Icon(icon, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
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
