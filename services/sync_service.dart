import 'dart:async';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';
import 'connectivity_service.dart';
import 'registro_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final HiveService _hive = HiveService();
  final ConnectivityService _connectivity = ConnectivityService();
  final RegistroService _registroService = RegistroService();

  StreamSubscription<bool>? _subscription;
  String? _token;

  void iniciar(String token) {
    _token = token;
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((hayRed) {
      if (hayRed) {
        debugPrint('SyncService: conexión recuperada — sincronizando...');
        _sincronizar();
      }
    });
    debugPrint('SyncService: escuchando cambios de conectividad');
  }

  void actualizarToken(String token) {
    _token = token;
  }

  void detener() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _sincronizar() async {
    if (_token == null) return;
    final pendientes = _hive.cargarPendientes();
    if (pendientes.isEmpty) {
      debugPrint('SyncService: no hay pendientes');
      return;
    }

    debugPrint('SyncService: ${pendientes.length} registros pendientes');

    for (final entry in pendientes) {
      final key = entry.key;
      final registro = entry.value;

      final success = await _registroService.crearRegistro(
        _token!,
        registro.rutinaId,
        registro.rutinaNombre,
        registro.numEjercicios,
      );

      if (success) {
        await _hive.eliminarPendiente(key);
        debugPrint('SyncService: registro sincronizado y eliminado de cola');
      } else {
        debugPrint('SyncService: fallo al sincronizar, reintentará más tarde');
        break;
      }
    }
  }

  Future<int> sincronizarAhora() async {
    if (_token == null) return 0;
    final antes = _hive.totalPendientes;
    await _sincronizar();
    return antes - _hive.totalPendientes;
  }

  int get totalPendientes => _hive.totalPendientes;
}