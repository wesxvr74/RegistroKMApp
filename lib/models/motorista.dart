import 'package:cloud_firestore/cloud_firestore.dart';

class Motorista {
  String id;
  String nome;
  String cnh;

  Motorista({required this.id, required this.nome, required this.cnh});

  // Factory constructor para criar um Motorista a partir de um DocumentSnapshot do Firestore
  factory Motorista.fromDocument(DocumentSnapshot doc) {
    return Motorista(
      id: doc.id,
      nome: doc['nome'] ?? '', // Use ?? '' para evitar erros caso o campo não exista
      cnh: doc['cnh'] ?? '',
    );
  }

  // Método para converter um objeto Motorista em um Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cnh': cnh,
    };
  }
}