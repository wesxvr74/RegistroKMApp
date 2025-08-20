import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar datas
import '../services/firestore_service.dart'; // Importa o serviço Firestore
import '../models/viagem.dart'; // Importa o modelo Viagem
import 'screens/map_screen.dart'; // Ajuste para importar tela de mapa

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios de Viagens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<List<Viagem>>(
                stream: firestoreService.getViagens(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(
                        'ReportScreen: Erro no StreamBuilder: ${snapshot.error}');
                    return const Center(
                        child: Text('Erro ao carregar viagens.'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final viagens = snapshot.data ?? [];

                  if (viagens.isEmpty) {
                    return const Center(
                        child: Text('Nenhuma viagem registrada ainda.'));
                  }

                  return ListView.builder(
                    itemCount: viagens.length,
                    itemBuilder: (context, index) {
                      final viagem = viagens[index];

                      final formattedDataInicio = viagem.dataInicio != null
                          ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(viagem.dataInicio)
                          : 'Data inválida';

                      final formattedDataFim = viagem.dataFim != null
                          ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(viagem.dataFim!)
                          : 'Em andamento';

                      final kmTotalFormatted =
                          viagem.kmTotal.toStringAsFixed(2);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text('Viagem ${viagem.id}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Início: $formattedDataInicio'),
                              Text('Fim: $formattedDataFim'),
                              Text('KM Percorrido: $kmTotalFormatted'),
                              // TODO: Exibir Motorista e Veículo
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.map),
                            tooltip: 'Visualizar no Mapa',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MapScreen(viagemId: viagem.id),
                                ),
                              );
                            },
                          ),
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
