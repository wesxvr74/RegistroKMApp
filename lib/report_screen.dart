import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'veiculo.dart';
import 'package:logging/logging.dart';
import 'motorista.dart';
import 'home.dart';
import 'main.dart' hide HomeScreen;

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

final _logger = Logger('ReportScreen');

class _ReportScreenState extends State<ReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedVeiculo;
  String? _selectedMotorista;
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;
  List<Veiculo> _veiculos = [];
  List<Motorista> _motoristas = [];

  @override
  void initState() {
    super.initState();
    _fetchFilterData();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _fetchFilterData() async {
    try {
      final veiculoSnapshot = await FirebaseFirestore.instance.collection('veiculos').get();
      final motoristaSnapshot = await FirebaseFirestore.instance.collection('motoristas').get();

      setState(() {
        _veiculos = veiculoSnapshot.docs.map((doc) => Veiculo.fromDocument(doc)).toList();
        _motoristas = motoristaSnapshot.docs.map((doc) => Motorista.fromDocument(doc)).toList();
      });
    } catch (e) {
      _logger.severe("Erro ao buscar dados: $e");
    }
  }

  Future<void> _performSearch() async {
    setState(() {
 if (_startDate == null || _endDate == null) {
 if (mounted) {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Por favor, selecione a data de início e fim.'),
 duration: Duration(seconds: 3),
 ),
 );
 }
 return; // Prevent search if dates are not selected
 }
      _isLoading = true;
      _searchResults = [];
    });
    Query<Map<String, dynamic>> currentQuery = FirebaseFirestore.instance.collection('registros_km');
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione a data de início e fim.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return; // Prevent search if dates are not selected
    }
    currentQuery = currentQuery.orderBy('data');
    currentQuery = currentQuery.where('data', isGreaterThanOrEqualTo: _startDate!.toIso8601String());
    final endOfEndDate = _endDate!.add(const Duration(days: 1));
    currentQuery = currentQuery.where('data', isLessThan: endOfEndDate.toIso8601String());
    if (_selectedVeiculo != null && _selectedVeiculo!.isNotEmpty) {
      currentQuery = currentQuery.where('veiculo.modelo', isEqualTo: _selectedVeiculo);
    }
    if (_selectedMotorista != null && _selectedMotorista!.isNotEmpty) {
      currentQuery = currentQuery.where('motorista.nome', isEqualTo: _selectedMotorista);
    }

    try {
      final querySnapshot = await currentQuery.get();
      setState(() {
        _searchResults = querySnapshot.docs;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('${_searchResults.length} registro(s) encontrado(s).'), duration: Duration(seconds: 3)),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar registros: ${e.toString()}')),
 );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios de Registro de KM')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: const Text('Tela Inicial'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Registrar KM'),
              onTap: () {
                Navigator.pushReplacement(
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
                Navigator.pushReplacement(
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MotoristaScreen()));
              }),
          ],
        )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Filtros de Pesquisa:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Data Início:'),
                    subtitle: Text(_startDate != null
                        ? DateFormat('dd/MM/yyyy').format(_startDate!)
                        : 'Selecionar'),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Data Fim:'),
                    subtitle: Text(_endDate != null
                        ? DateFormat('dd/MM/yyyy').format(_endDate!)
                        : 'Selecionar'),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Veículo'),
              value: _selectedVeiculo,
              items: _veiculos.map((veiculo) {
                return DropdownMenuItem<String>(
                  value: veiculo.modelo,
                  child: Text('${veiculo.modelo} - ${veiculo.placa}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedVeiculo = val),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Motorista'),
              value: _selectedMotorista,
              items: _motoristas.map((motorista) {
                return DropdownMenuItem<String>(
                  value: motorista.nome,
                  child: Text(motorista.nome),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedMotorista = val),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: const Text('Pesquisar'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Resultados da Pesquisa:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final data = _searchResults[index].data() as Map<String, dynamic>;

                  final km = data['km'] ?? 'N/A';
                  final veiculoModelo = data['veiculo']?['modelo'] ?? 'N/A';
                  final veiculoPlaca = data['veiculo']?['placa'] ?? 'N/A';
                  final motoristaNome = data['motorista']?['nome'] ?? 'N/A';
                  final local = data['location'] ?? 'N/A';
                  final tipo = data['tipo'] ?? 'N/A';

                  final dataString = data['data'] ?? '';
                  String formattedDate = 'N/A';
                  try {
                    final recordDate = DateTime.parse(dataString);
                    formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(recordDate);
                  } catch (_) {}

                  return ListTile(
                    title: Text('KM: $km, Local: $local, Tipo: $tipo'),
                    subtitle: Text(
                      'Veículo: $veiculoModelo ($veiculoPlaca), Motorista: $motoristaNome, Data: $formattedDate',
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
