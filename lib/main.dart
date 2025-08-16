import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'veiculo.dart';
import 'motorista.dart';
import 'car_mileage_screen.dart';
import 'report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RegistroKMApp());
}

class RegistroKMApp extends StatelessWidget {
  const RegistroKMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de KM',
      theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.white),
      home: const HomeScreen(),
    );
  }
}

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
                );
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
            ListTile(
              title: const Text('KM Rodado por Veículo'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CarMileageScreen(),
                  ),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MileageRegistrationPage(),
                    ),
                  );
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

class MileageRegistrationPage extends StatefulWidget {
  const MileageRegistrationPage({super.key});

  @override
  _MileageRegistrationPageState createState() =>
      _MileageRegistrationPageState();
}

class _MileageRegistrationPageState extends State<MileageRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedVeiculo;
  String? _tipoDeslocamento;
  String? _selectedMotorista;
  DateTime _selectedDate = DateTime.now();
  List<Veiculo> _availableVeiculos = [];
  List<Motorista> _availableMotoristas = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAvailableData();
  }

  void _fetchAvailableData() async {
    final veiculoSnapshot =
        await FirebaseFirestore.instance.collection('veiculos').get();
    final motoristaSnapshot =
        await FirebaseFirestore.instance.collection('motoristas').get();

    setState(() {
      _availableVeiculos =
          veiculoSnapshot.docs.map((doc) => Veiculo.fromDocument(doc)).toList();
      _availableMotoristas =
          motoristaSnapshot.docs
              .map((doc) => Motorista.fromDocument(doc))
              .toList();
    });
  }

  void _registerMileage() async {
    if (_formKey.currentState!.validate()) {
      final selectedVeiculo = _availableVeiculos.firstWhere(
        (v) => v.modelo == _selectedVeiculo,
      );
      final selectedMotorista = _availableMotoristas.firstWhere(
        (m) => m.nome == _selectedMotorista,
      );

      await FirebaseFirestore.instance.collection('registros_km').add({
        'km': int.parse(_kmController.text),
        'veiculo': {
          'modelo': selectedVeiculo.modelo,
          'placa': selectedVeiculo.placa,
        },
        'location': _locationController.text,
        'tipo': _tipoDeslocamento,
        'motorista': {'nome': selectedMotorista.nome},
        'data': _selectedDate.toIso8601String(),
      });

      _kmController.clear();
      _locationController.clear();
      setState(() {
        _selectedVeiculo = null;
        _tipoDeslocamento = null;
        _selectedMotorista = null;
        _selectedDate = DateTime.now();
      });

      if (!mounted) return;

      // Mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro de KM salvo com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Voltar para tela inicial limpando o histórico
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _kmController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de KM')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(labelText: 'KM'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o KM';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Veículo'),
                value: _selectedVeiculo,
                items:
                    _availableVeiculos.map((veiculo) {
                      return DropdownMenuItem<String>(
                        value: veiculo.modelo,
                        child: Text('${veiculo.modelo} - ${veiculo.placa}'),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _selectedVeiculo = val),
                validator:
                    (value) => value == null ? 'Selecione um veículo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Local'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o local';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Deslocamento',
                ),
                value: _tipoDeslocamento,
                items:
                    ['Saindo', 'Chegando']
                        .map(
                          (tipo) =>
                              DropdownMenuItem(value: tipo, child: Text(tipo)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _tipoDeslocamento = val),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o tipo de deslocamento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Motorista'),
                value: _selectedMotorista,
                items:
                    _availableMotoristas.map((motorista) {
                      return DropdownMenuItem<String>(
                        value: motorista.nome,
                        child: Text(motorista.nome),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _selectedMotorista = val),
                validator:
                    (value) =>
                        value == null ? 'Por favor, insira o motorista' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerMileage,
                child: const Text('Registrar KM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
