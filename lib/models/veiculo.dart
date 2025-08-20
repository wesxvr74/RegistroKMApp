import 'package:cloud_firestore/cloud_firestore.dart';

class Veiculo {
  String id;
  String placa;
  String modelo;

  Veiculo({required this.id, required this.placa, required this.modelo});

  // Factory constructor para criar um Veiculo a partir de um DocumentSnapshot do Firestore
  factory Veiculo.fromDocument(DocumentSnapshot doc) {
    return Veiculo(
      id: doc.id,
      placa: doc['placa'] ?? '', // Use ?? '' para evitar erros caso o campo não exista
      modelo: doc['modelo'] ?? '',
    );
  }

  // Método para converter um objeto Veiculo em um Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'placa': placa,
      'modelo': modelo,
    };
  }
}