import 'package:cloud_firestore/cloud_firestore.dart';

class Localizacao {
  String id;
  double latitude;
  double longitude;
  DateTime timestamp;

  Localizacao({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  // Factory constructor para criar uma Localizacao a partir de um DocumentSnapshot do Firestore
  factory Localizacao.fromDocument(DocumentSnapshot doc) {
    return Localizacao(
      id: doc.id,
      latitude: (doc['latitude'] as num?)?.toDouble() ?? 0.0, // Pode ser nulo
      longitude: (doc['longitude'] as num?)?.toDouble() ?? 0.0, // Pode ser nulo
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }

  // Método para converter um objeto Localizacao em um Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}