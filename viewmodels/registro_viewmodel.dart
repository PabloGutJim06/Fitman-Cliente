// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'package:flutter/foundation.dart';
import '../models/registro_model.dart';
import '../services/registro_service.dart';

class RegistroViewModel extends ChangeNotifier {
  final RegistroService _service = RegistroService();

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

    try {
      // Cargamos lista y resumen en paralelo — más eficiente que secuencial
      final results = await Future.wait([
        _service.obtenerRegistros(token),
        _service.obtenerResumen(token),
      ]);

      _registros = results[0] as List<RegistroModel>;
      final resumen = results[1] as Map<String, int>;
      _totalEntrenamientos = resumen['total'] ?? 0;
      _esteMes = resumen['este_mes'] ?? 0;
    } catch (e) {
      _errorMessage = 'No se pudieron cargar los registros.';
      debugPrint('Error en loadRegistros: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completarEntrenamiento(
      String token,
      String rutinaId,
      String rutinaNombre,
      int numEjercicios,
      ) async {
    final success = await _service.crearRegistro(
      token,
      rutinaId,
      rutinaNombre,
      numEjercicios,
    );

    if (success) {
      // Recargamos todo para que historial y contadores estén actualizados
      await loadRegistros(token);
    }

    return success;
  }
}