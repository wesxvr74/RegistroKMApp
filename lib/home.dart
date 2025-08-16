import 'package:flutter/material.dart';
import 'veiculo.dart';
import 'motorista.dart';
import 'report_screen.dart';
import 'main.dart'; // Certifique-se de que MileageRegistrationPage esteja em main.dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de KM')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: const Text('Registrar KM'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MileageRegistrationPage(),
                  ),
                ).then((result) {
                  if (!context.mounted) return;

                  if (result == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registro de KM salvo com sucesso!'),
                      ),
                    );
                  } else if (result == 'cancel') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registro de KM cancelado.'),
                      ),
                    );
                  }
                });
              },
            ),
            ListTile(
              title: const Text('Veículos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VeiculoScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Motoristas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MotoristaScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Relatórios'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              elevation: 4.0,
              child: ListTile(
                leading: const Icon(Icons.add_road),
                title: const Text('Registrar KM'),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MileageRegistrationPage(),
                    ),
                  );
                  if (result == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registro de KM salvo com sucesso!'),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4.0,
              child: ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Cadastro de Veículos'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VeiculoScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4.0,
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Cadastro de Motoristas'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MotoristaScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4.0,
              child: ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Relatórios'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
