import 'package:cloud_firestore/cloud_firestore.dart';

class Viagem {
  String id;
  String motoristaId;
  String veiculoId;
  DateTime dataInicio;
  DateTime? dataFim; // Opcional, para viagens em andamento
  double kmTotal;
  String pontoSaida;
  String? pontoChegada; // Opcional, para viagens em andamento

  Viagem({
    required this.id,
    required this.motoristaId,
    required this.veiculoId,
    required this.dataInicio,
    this.dataFim,
    this.kmTotal = 0.0, // Inicia com 0
    required this.pontoSaida,
    this.pontoChegada,
  });

  // Factory constructor para criar uma Viagem a partir de um DocumentSnapshot do Firestore
  factory Viagem.fromDocument(DocumentSnapshot doc) {
    return Viagem(
      id: doc.id,
      motoristaId: doc['motoristaId'] ?? '',
      veiculoId: doc['veiculoId'] ?? '',
      dataInicio: (doc['dataInicio'] as Timestamp).toDate(),
      dataFim: (doc['dataFim'] as Timestamp?)?.toDate(), // Pode ser nulo
      kmTotal: (doc['kmTotal'] as num?)?.toDouble() ?? 0.0, // Pode ser nulo
      pontoSaida: doc['pontoSaida'] ?? '',
      pontoChegada: doc['pontoChegada'], // Pode ser nulo
    );
  }

  // Método para converter um objeto Viagem em um Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'motoristaId': motoristaId,
      'veiculoId': veiculoId,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': dataFim != null ? Timestamp.fromDate(dataFim!) : null, // Pode ser nulo
      'kmTotal': kmTotal,
      'pontoSaida': pontoSaida,
      'pontoChegada': pontoChegada, // Pode ser nulo
    };
  }

   // Método copyWith para criar uma cópia da Viagem com atributos modificados
  Viagem copyWith({
    String? id,
    String? motoristaId,
    String? veiculoId,
    DateTime? dataInicio,
    DateTime? dataFim,
    double? kmTotal,
    String? pontoSaida,
    String? pontoChegada,
  }) {
    return Viagem(
      id: id ?? this.id,
      motoristaId: motoristaId ?? this.motoristaId,
      veiculoId: veiculoId ?? this.veiculoId,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      kmTotal: kmTotal ?? this.kmTotal,
      pontoSaida: pontoSaida ?? this.pontoSaida,
      pontoChegada: pontoChegada ?? this.pontoChegada,
    );
  }
}