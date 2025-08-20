import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/motorista.dart';
import '../models/veiculo.dart';
import '../models/viagem.dart';
import '../models/localizacao.dart';
import 'firebase_service.dart';

class FirestoreService {
   // Garante que haja apenas uma instância do FirestoreService
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  // Instância do FirebaseFirestore obtida do FirebaseService
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  // Referências às Coleções principais como Getters

  // TODO: Implementar isolamento de dados por usuário usando o ID do usuário logado
  // Quando isolar por usuário, estes getters devem usar o ID do usuário autenticado.
  // Exemplo: CollectionReference get _motoristasCollection => _firestore.collection('users').doc(FirebaseService().getCurrentUser()!.uid).collection('motoristas');

  CollectionReference get _motoristasCollection => _firestore.collection('motoristas');
  CollectionReference get _veiculosCollection => _firestore.collection('veiculos');
  CollectionReference get _viagensCollection => _firestore.collection('viagens');


  // --- Métodos para Motoristas ---

  // Adiciona um novo motorista
  Future<void> addMotorista(Motorista motorista) async {
    try {
       // Usa o getter para acessar a referência da coleção
       await _motoristasCollection.add(motorista.toMap());
       print('FirestoreService: Motorista adicionado com sucesso.');
    } catch (e) {
       print('FirestoreService: Erro ao adicionar motorista: $e');
       rethrow;
    }
  }

  // Obtém todos os motoristas
  Stream<List<Motorista>> getMotoristas() {
     // Usa o getter para acessar a referência da coleção
    return _motoristasCollection.snapshots().map((snapshot) {
       print('FirestoreService: Obtendo stream de motoristas com ${snapshot.docs.length} documentos.');
      return snapshot.docs.map((doc) => Motorista.fromDocument(doc)).toList();
    }).handleError((error) {
       print('FirestoreService: Erro no stream de motoristas: $error');
    });
  }

  // Atualiza um motorista existente
  Future<void> updateMotorista(Motorista motorista) async {
     try {
        // Usa o getter para acessar a referência da coleção
       await _motoristasCollection.doc(motorista.id).update(motorista.toMap());
        print('FirestoreService: Motorista ${motorista.id} atualizado com sucesso.');
     } catch (e) {
       print('FirestoreService: Erro ao atualizar motorista ${motorista.id}: $e');
       rethrow;
     }
  }

  // Deleta um motorista
  Future<void> deleteMotorista(String motoristaId) async {
     try {
        // Usa o getter para acessar a referência da coleção
       await _motoristasCollection.doc(motoristaId).delete();
       print('FirestoreService: Motorista $motoristaId deletado com sucesso.');
     } catch (e) {
       print('FirestoreService: Erro ao deletar motorista $motoristaId: $e');
       rethrow;
     }
  }

  // --- Métodos para Veículos ---

  // Adiciona um novo veículo
  Future<void> addVeiculo(Veiculo veiculo) async {
     try {
        // Usa o getter para acessar a referência da coleção
        await _veiculosCollection.add(veiculo.toMap());
        print('FirestoreService: Veículo adicionado com sucesso.');
     } catch (e) {
       print('FirestoreService: Erro ao adicionar veículo: $e');
       rethrow;
     }
  }

  // Obtém todos os veículos
  Stream<List<Veiculo>> getVeiculos() {
     // Usa o getter para acessar a referência da coleção
    return _veiculosCollection.snapshots().map((snapshot) {
       print('FirestoreService: Obtendo stream de veículos com ${snapshot.docs.length} documentos.');
      return snapshot.docs.map((doc) => Veiculo.fromDocument(doc)).toList();
    }).handleError((error) {
       print('FirestoreService: Erro no stream de veículos: $error');
    });
  }

  // Atualiza um veículo existente
  Future<void> updateVeiculo(Veiculo veiculo) async {
     try {
        // Usa o getter para acessar a referência da coleção
       await _veiculosCollection.doc(veiculo.id).update(veiculo.toMap());
       print('FirestoreService: Veículo ${veiculo.id} atualizado com sucesso.');
     } catch (e) {
       print('FirestoreService: Erro ao atualizar veículo ${veiculo.id}: $e');
       rethrow;
     }
  }

  // Deleta um veículo
  Future<void> deleteVeiculo(String veiculoId) async {
     try {
        // Usa o getter para acessar a referência da coleção
        await _veiculosCollection.doc(veiculoId).delete();
        print('FirestoreService: Veículo $veiculoId deletado com sucesso.');
     } catch (e) {
       print('FirestoreService: Erro ao deletar veículo $veiculoId: $e');
       rethrow;
     }
  }

  // --- Métodos para Viagens ---

  // Adiciona uma nova viagem
  Future<DocumentReference> addViagem(Viagem viagem) async {
     try {
        // Usa o getter para acessar a referência da coleção
        final docRef = await _viagensCollection.add(viagem.toMap());
        print('FirestoreService: Viagem adicionada com sucesso com ID ${docRef.id}.');
        return docRef;
     } catch (e) {
       print('FirestoreService: Erro ao adicionar viagem: $e');
       rethrow;
     }
  }

  // Obtém todas as viagens
  Stream<List<Viagem>> getViagens() {
     // Usa o getter para acessar a referência da coleção
    return _viagensCollection
        .orderBy('dataInicio', descending: true)
        .snapshots()
        .map((snapshot) {
           print('FirestoreService: Obtendo stream de viagens com ${snapshot.docs.length} documentos.');
           return snapshot.docs.map((doc) => Viagem.fromDocument(doc)).toList();
        }).handleError((error) {
           print('FirestoreService: Erro no stream de viagens: $error');
        });
  }

  // Obtém uma viagem por ID
  Future<Viagem?> getViagemById(String viagemId) async {
     try {
       // Usa o getter para acessar a referência da coleção
       final doc = await _viagensCollection.doc(viagemId).get();
       if (doc.exists) {
          print('FirestoreService: Viagem $viagemId encontrada.');
         return Viagem.fromDocument(doc);
       }
        print('FirestoreService: Viagem $viagemId não encontrada.');
       return null;
     } catch (e) {
       print('FirestoreService: Erro ao obter viagem por ID $viagemId: $e');
       rethrow;
     }
  }

  // Atualiza uma viagem existente
  Future<void> updateViagem(Viagem viagem) async {
     try {
        // Usa o getter para acessar a referência da coleção
       await _viagensCollection.doc(viagem.id).update(viagem.toMap());
       print('FirestoreService: Viagem ${viagem.id} atualizada com sucesso.');
     } catch (e) {
       print('FirestoreService: Erro ao atualizar viagem ${viagem.id}: $e');
       rethrow;
     }
  }

  // Deleta uma viagem
  Future<void> deleteViagem(String viagemId) async {
     try {
        // Usa o getter para acessar a referência da coleção
        await _viagensCollection.doc(viagemId).delete();
        print('FirestoreService: Viagem $viagemId deletada com sucesso.');
     } catch (e) {
       print('FirestoreService: Erro ao deletar viagem $viagemId: $e');
       rethrow;
     }
  }

  // Método para atualizar apenas o kmTotal de uma viagem
  Future<void> updateViagemKm(String viagemId, double kmTotal) async {
     try {
        // Usa o getter para acessar a referência da coleção
        await _viagensCollection.doc(viagemId).update({'kmTotal': kmTotal});
        print('FirestoreService: KM total da viagem $viagemId atualizado para $kmTotal.');
     } catch (e) {
        print('FirestoreService: Erro ao atualizar KM total da viagem $viagemId: $e');
        rethrow;
     }
  }


  // --- Métodos para Localizações (Subcoleção de Viagem) ---

  // Adiciona uma nova localização a uma viagem
  Future<void> addLocalizacao(String viagemId, Localizacao localizacao) async {
     try {
        // Cria a referência da subcoleção usando o ID da viagem
        final localizacoesCollection = _viagensCollection.doc(viagemId).collection('localizacoes');
        await localizacoesCollection.add(localizacao.toMap());
        print('FirestoreService: Localização adicionada à viagem $viagemId.');
     } catch (e) {
       print('FirestoreService: Erro ao adicionar localização à viagem $viagemId: $e');
       rethrow;
     }
  }

  // Obtém todas as localizações de uma viagem
  Stream<List<Localizacao>> getLocalizacoes(String viagemId) {
     // Cria a referência da subcoleção usando o ID da viagem
     final localizacoesCollection = _viagensCollection.doc(viagemId).collection('localizacoes');
    return localizacoesCollection
        .orderBy('timestamp') // Ordena por timestamp (ordem cronológica)
        .snapshots()
        .map((snapshot) {
           print('FirestoreService: Obtendo stream de localizações para viagem $viagemId com ${snapshot.docs.length} documentos.');
           return snapshot.docs.map((doc) => Localizacao.fromDocument(doc)).toList();
        }).handleError((error) {
           print('FirestoreService: Erro no stream de localizações para viagem $viagemId: $error');
        });
  }

   // TODO: Adicionar regras de segurança no Firestore para proteger os dados
   // Exemplo: permitir que apenas usuários autenticados leiam e escrevam em suas próprias coleções
   // Consulte a documentação do Firebase Security Rules: https://firebase.google.com/docs/firestore/security/get-started
}
