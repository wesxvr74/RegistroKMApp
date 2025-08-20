import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // Necessário para ValueNotifier
import 'package:geolocator/geolocator.dart';
import '../models/localizacao.dart';
import '../services/firestore_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<Position>? _positionSubscription;
  String? _currentViagemId;
  Position? _lastPosition;
  double _currentViagemKm = 0.0;
  final ValueNotifier<double> currentViagemKmNotifier = ValueNotifier<double>(0.0);

  Future<bool> startTracking(String viagemId) async {
    _currentViagemId = viagemId;
    _lastPosition = null;
    _currentViagemKm = 0.0;
    currentViagemKmNotifier.value = 0.0;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    if (!await Geolocator.isLocationServiceEnabled()) return false;

    try {
      _lastPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (_lastPosition != null) {
        final initialLocalizacao = Localizacao(
          id: '',
          latitude: _lastPosition!.latitude,
          longitude: _lastPosition!.longitude,
          timestamp: _lastPosition!.timestamp ?? DateTime.now(),
        );
        await _firestoreService.addLocalizacao(_currentViagemId!, initialLocalizacao);
      }
    } catch (e) {
      print('Erro ao obter posição inicial: $e');
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) => _onLocationUpdate(position),
                onError: (error) => print('Erro no stream de localização: $error'));

    return true;
  }

  Future<void> _onLocationUpdate(Position position) async {
    if (_currentViagemId == null) return;

    final newLocalizacao = Localizacao(
      id: '',
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp ?? DateTime.now(),
    );

    try {
      await _firestoreService.addLocalizacao(_currentViagemId!, newLocalizacao);

      if (_lastPosition != null) {
        double distanceInMeters = _calculateDistance(
            _lastPosition!.latitude, _lastPosition!.longitude,
            position.latitude, position.longitude);

        if (distanceInMeters < 1) return;

        double distanceInKm = distanceInMeters / 1000.0;
        _currentViagemKm += distanceInKm;
        currentViagemKmNotifier.value = _currentViagemKm;

        await _firestoreService.updateViagemKm(_currentViagemId!, _currentViagemKm);
      }

      _lastPosition = position;
    } catch (e) {
      print('Erro ao processar localização ou atualizar Firestore: $e');
    }
  }

  Future<void> stopTracking() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    if (_currentViagemId != null) {
      try {
        final viagem = await _firestoreService.getViagemById(_currentViagemId!);
        if (viagem != null) {
          viagem.dataFim = DateTime.now();
          viagem.kmTotal = _currentViagemKm;
          await _firestoreService.updateViagem(viagem);
        }
      } catch (e) {
        print('Erro ao encerrar viagem no Firestore: $e');
      }
    }

    _currentViagemId = null;
    _lastPosition = null;
    _currentViagemKm = 0.0;
    currentViagemKmNotifier.value = 0.0;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
               cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
               sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;
}
