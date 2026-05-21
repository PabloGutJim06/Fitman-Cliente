import 'package:flutter/foundation.dart';
import '../models/registro_model.dart';
import '../services/registro_service.dart';
import '../services/hive_service.dart';
import '../services/connectivity_service.dart';

class RegistroViewModel extends ChangeNotifier {
  final RegistroService _service = RegistroService();
  final HiveService _hive = HiveService();
  final ConnectivityService _connectivity = ConnectivityService();

  List<RegistroModel> _registros = [];
  int _totalEntrenamientos = 0;
  int _esteMes = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<RegistroModel> get registros => _registros;

  int get totalEntrenamientos => _totalEntrenamientos;

  int get esteMes => _esteMes;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadRegistros(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final hayRed = await _connectivity.tieneConexion();

    if (hayRed) {
      try {
        final results = await Future.wait([
          _service.obtenerRegistros(token),
          _service.obtenerResumen(token),
        ]);
        _registros = results[0] as List<RegistroModel>;
        final resumen = results[1] as Map<String, int>;
        _totalEntrenamientos = resumen['total'] ?? 0;
        _esteMes = resumen['este_mes'] ?? 0;
        await _hive.guardarRegistros(_registros);
      } catch (e) {
        _errorMessage = 'No se pudieron cargar los registros.';
      }
    } else {
      _registros = _hive.cargarRegistros();
      final ahora = DateTime.now();
      _totalEntrenamientos = _registros.length;
      _esteMes = _registros
          .where((r) =>
      r.fecha.year == ahora.year && r.fecha.month == ahora.month)
          .length;
      debugPrint(
          'RegistroViewModel: ${_registros.length} registros de caché');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> completarEntrenamiento(String token,
      String rutinaId,
      String rutinaNombre,
      int numEjercicios,) async {
    final hayRed = await _connectivity.tieneConexion();

    if (hayRed) {
      final success = await _service.crearRegistro(
          token, rutinaId, rutinaNombre, numEjercicios);
      if (success) await loadRegistros(token);
      return success;
    } else {
      await _hive.encolarRegistro(PendingRegistro(
        rutinaId: rutinaId,
        rutinaNombre: rutinaNombre,
        numEjercicios: numEjercicios,
        fecha: DateTime.now(),
      ));
      debugPrint('RegistroViewModel: entrenamiento encolado para sync');
      return true;
    }
  }
}