import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Importa para tipos Firestore, se necessário
import '../models/localizacao.dart';
import '../models/viagem.dart';
import '../services/firestore_service.dart'; // Importa o serviço Firestore

class MapScreen extends StatefulWidget {
  final String viagemId; // ID da viagem a ser exibida no mapa

  const MapScreen({super.key, required this.viagemId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  GoogleMapController? _controller; // Controlador do Google Maps
  final Set<Marker> _markers = {}; // Conjunto de marcadores no mapa (usando final)
  final Set<Polyline> _polylines = {}; // Conjunto de polylines no mapa (usando final)
  final List<LatLng> _routePoints = []; // Pontos da rota (usando final)
  Viagem? _viagem; // Dados da viagem
  StreamSubscription<List<Localizacao>>? _localizacoesSubscription; // Assinatura para localizações

  // Posição inicial da câmera (fallback)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-23.550520, -46.633308), // Exemplo: Centro de São Paulo
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadViagemAndStartListening(); // Renomeada a função para clareza
  }

  @override
  void dispose() {
    // Cancela a assinatura e descarta o controlador ao sair da tela
    _localizacoesSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  // Carrega os dados da viagem e inicia a escuta por localizações
  Future<void> _loadViagemAndStartListening() async {
    try {
      _viagem = await _firestoreService.getViagemById(widget.viagemId);
      if (_viagem == null) {
        // Tratar corretamente viagem não encontrada
        print('MapScreen: Viagem com ID ${widget.viagemId} não encontrada.');
        if (mounted) { // Verifica se o widget ainda está ativo antes de mostrar SnackBar
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Viagem não encontrada.')),
            );
            // Opcionalmente, navegar de volta:
            // Navigator.pop(context);
        }
         return; // Sai da função se a viagem não for encontrada
      }
       print('MapScreen: Viagem ${_viagem!.id} carregada. Iniciando escuta de localizações.');
      _listenToLocalizacoes(); // Inicia a escuta apenas se a viagem for encontrada
    } catch (e) {
       // Lidar com erro ao carregar viagem
       print('MapScreen: Erro ao carregar viagem ${widget.viagemId}: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar viagem: $e')),
          );
          // Opcionalmente, navegar de volta:
          // Navigator.pop(context);
        }
    }
  }

  // Inicia a escuta em tempo real das localizações da viagem
  void _listenToLocalizacoes() {
    // Garante que não haja assinaturas duplicadas
    _localizacoesSubscription?.cancel();

    // Assina o stream de localizações e trata erros e dados
    _localizacoesSubscription = _firestoreService.getLocalizacoes(widget.viagemId)
        .handleError((error) {
           // Lidar com erros no stream de localizações
           print('MapScreen: Erro no stream de localizações para viagem ${widget.viagemId}: $error');
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao obter localizações: $error')),
              );
           }
           // Continua ouvindo o stream, mas trata o erro
        })
        .listen((localizacoes) {
           print('MapScreen: ${localizacoes.length} localizações recebidas.');
           _updateMap(localizacoes);
        });
  }

  // Atualiza o mapa com as novas localizações
  void _updateMap(List<Localizacao> localizacoes) {
    _routePoints.clear();
    _markers.clear();
    _polylines.clear(); // Limpa também as polylines para redesenhar

    if (localizacoes.isNotEmpty) {
      // Adiciona os pontos à rota
      _routePoints.addAll(localizacoes.map((loc) => LatLng(loc.latitude, loc.longitude)));

      // Adiciona marcador para o ponto inicial (verde)
      final startPoint = localizacoes.first;
      _markers.add(Marker(
        markerId: const MarkerId('start_point'),
        position: LatLng(startPoint.latitude, startPoint.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Início da Viagem', snippet: _viagem?.pontoSaida ?? 'N/A'),
      ));

      // Adiciona marcador para o ponto final (vermelho) se a viagem estiver encerrada e houver mais de um ponto
      if (_viagem?.dataFim != null && localizacoes.length > 1) {
        final endPoint = localizacoes.last;
        _markers.add(Marker(
          markerId: const MarkerId('end_point'),
          position: LatLng(endPoint.latitude, endPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
           infoWindow: InfoWindow(title: 'Fim da Viagem', snippet: _viagem?.pontoChegada ?? 'N/A'),
        ));
      }

      // Cria a polyline para desenhar o trajeto se houver pelo menos dois pontos
      if (_routePoints.length > 1) {
        _polylines.add(Polyline(
          polylineId: PolylineId(widget.viagemId),
          points: _routePoints,
          color: Colors.blue, // Cor da linha do trajeto
          width: 5,
        ));
      }

      // Move a câmera para o último ponto da rota (se houver controlador e pontos)
      if (_controller != null && _routePoints.isNotEmpty) {
        _controller!.animateCamera(
          CameraUpdate.newLatLng(_routePoints.last),
        );
      }
    }

    // Atualiza a UI para mostrar os marcadores e a polyline
    if (mounted) { // Verifica se o widget ainda está ativo antes de chamar setState
      setState(() {});
    }
  }

  // Callback quando o mapa é criado
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    // Move a câmera para a primeira posição da rota se houver pontos ao criar o mapa
    if (_routePoints.isNotEmpty) {
       _controller!.animateCamera(
          CameraUpdate.newLatLng(_routePoints.first),
        );
    } else {
      // Move a câmera para a posição inicial padrão se não houver pontos ainda
      _controller!.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        );
    }
     print('MapScreen: Mapa criado.');
  }

  @override
  Widget build(BuildContext context) {
    // Exibe um indicador de carregamento enquanto a viagem não for carregada e não houver pontos
    if (_viagem == null && _routePoints.isEmpty) {
       return Scaffold(
         appBar: AppBar(title: const Text('Carregando Trajeto...')),
         body: const Center(child: CircularProgressIndicator()),
       );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trajeto da Viagem: ${widget.viagemId}'),
      ),
      body: GoogleMap(
          onMapCreated: _onMapCreated,
           // Define a posição inicial da câmera. Usa o primeiro ponto da rota se disponível, senão o fallback.
          initialCameraPosition: _routePoints.isNotEmpty
              ? CameraPosition(target: _routePoints.first, zoom: 14)
              : _initialCameraPosition,
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true, // Mostra a localização do usuário (opcional)
          myLocationButtonEnabled: true, // Botão para focar na localização do usuário (opcional) - Requer permissão de localização
          // mapType: MapType.hybrid, // Exemplo de outro tipo de mapa
        ),
    );
  }
}
