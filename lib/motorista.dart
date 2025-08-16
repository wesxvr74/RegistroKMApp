import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Motorista {
  String id;
  String nome;

  Motorista({required this.id, required this.nome});

  factory Motorista.fromDocument(DocumentSnapshot doc) {
    return Motorista(
      id: doc.id,
      nome: doc['nome'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
    };
  }
}

class MotoristaScreen extends StatefulWidget {
  const MotoristaScreen({super.key});

  @override
  State<MotoristaScreen> createState() => _MotoristaScreenState();
}

class _MotoristaScreenState extends State<MotoristaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Motoristas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nome:'),
                  TextFormField(
                    controller: _nomeController,
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        FirebaseFirestore.instance.collection('motoristas').add({
                          'nome': _nomeController.text,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Motorista salvo com sucesso!')),
                        );
                        _formKey.currentState!.reset();
                        _nomeController.clear();
                      }
                    },
                    child: const Text('Salvar Motorista'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Lista de Motoristas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('motoristas').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final motoristas = snapshot.data!.docs.map((doc) => Motorista.fromDocument(doc)).toList();
                  return ListView.builder(
                    itemCount: motoristas.length,
                    itemBuilder: (context, index) {
                      final motorista = motoristas[index];
                      return ListTile(
                        title: Text(motorista.nome),
                         trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('motoristas').doc(motorista.id).delete();
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