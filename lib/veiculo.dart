import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Veiculo {
  String id;
  String modelo;
  String placa;

  Veiculo({required this.id, required this.modelo, required this.placa});

  factory Veiculo.fromDocument(DocumentSnapshot doc) {
    return Veiculo(
      id: doc.id,
      modelo: doc['modelo'],
      placa: doc['placa'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'placa': placa,
    };
  }
}

class VeiculoScreen extends StatefulWidget {
  const VeiculoScreen({super.key});

  @override
  State<VeiculoScreen> createState() => _VeiculoScreenState();
}

class _VeiculoScreenState extends State<VeiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Veículos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modelo:'),
                  TextFormField(
                    controller: _modeloController,
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Placa:'),
                  TextFormField(
                    controller: _placaController,
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        FirebaseFirestore.instance.collection('veiculos').add({
                          'modelo': _modeloController.text,
                          'placa': _placaController.text,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veículo salvo com sucesso!')),
                        );
                        _formKey.currentState!.reset();
                        _modeloController.clear();
                        _placaController.clear();
                      }
                    },
                    child: const Text('Salvar Veículo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Lista de Veículos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('veiculos').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final veiculos = snapshot.data!.docs.map((doc) => Veiculo.fromDocument(doc)).toList();
                  return ListView.builder(
                    itemCount: veiculos.length,
                    itemBuilder: (context, index) {
                      final veiculo = veiculos[index];
                      return ListTile(
                        title: Text('${veiculo.modelo} - ${veiculo.placa}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('veiculos').doc(veiculo.id).delete();
                          },
                        ),
                      );
                    },
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