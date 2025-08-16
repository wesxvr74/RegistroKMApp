import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'veiculo.dart'; // Assuming you have this file

class CarMileageScreen extends StatefulWidget {
  const CarMileageScreen({super.key});

  @override
  _CarMileageScreenState createState() => _CarMileageScreenState();
}

class _CarMileageScreenState extends State<CarMileageScreen> {
  String? _selectedVeiculo;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Veiculo> _availableVeiculos = [];
  int? _totalKm;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableVeiculos();
  }

  Future<void> _fetchAvailableVeiculos() async {
    try {
      final veiculoSnapshot =
          await FirebaseFirestore.instance.collection('veiculos').get();
      setState(() {
        _availableVeiculos =
            veiculoSnapshot.docs.map((doc) => Veiculo.fromDocument(doc)).toList();
      });
    } catch (e) {
      // Handle error, maybe show a snackbar
      print('Error fetching vehicles: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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

  Future<void> _calculateMileage() async {
    if (_selectedVeiculo == null || _startDate == null || _endDate == null) {
      // Show a snackbar or dialog prompting the user to select all fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione o veículo, data de início e data de fim.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _totalKm = null;
    });

    try {
      // Fetch mileage records for the selected vehicle and date range
      final querySnapshot = await FirebaseFirestore.instance
          .collection('registros_km')
          .where('veiculo.modelo', isEqualTo: _selectedVeiculo)
          .where('data', isGreaterThanOrEqualTo: _startDate!.toIso8601String())
          .where('data', isLessThan: _endDate!.add(const Duration(days: 1)).toIso8601String())
          .orderBy('data')
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _totalKm = 0; // No records found
        });
        return;
      }

      // Find the minimum and maximum KM values
      int minKm = querySnapshot.docs.first.data()['km'];
      int maxKm = querySnapshot.docs.last.data()['km'];

      setState(() {
        _totalKm = maxKm - minKm;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _totalKm = null; // Indicate error
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao calcular KM: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KM Rodado por Veículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Veículo'),
              value: _selectedVeiculo,
              items: _availableVeiculos.map((veiculo) {
                return DropdownMenuItem<String>(
                  value: veiculo.modelo,
                  child: Text('${veiculo.modelo} - ${veiculo.placa}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedVeiculo = val),
              validator: (value) => value == null ? 'Selecione um veículo' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Data Início:'),
              subtitle: Text(_startDate != null
                  ? DateFormat('dd/MM/yyyy').format(_startDate!)
                  : 'Selecionar'),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: const Text('Data Fim:'),
              subtitle: Text(_endDate != null
                  ? DateFormat('dd/MM/yyyy').format(_endDate!)
                  : 'Selecionar'),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _calculateMileage,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Calcular KM Rodado'),
            ),
            const SizedBox(height: 20),
            if (_totalKm != null)
              Center(
                child: Text(
                  'KM Rodado no Período: $_totalKm KM',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}