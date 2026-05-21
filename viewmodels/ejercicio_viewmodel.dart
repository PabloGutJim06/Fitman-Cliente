import 'package:flutter/foundation.dart';
import '../models/ejercicio_global_model.dart';
import '../services/ejercicio_service.dart';

class EjercicioViewModel extends ChangeNotifier {
  final EjercicioService _service = EjercicioService();

  List<EjercicioGlobalModel> _todos = [];
  List<EjercicioGlobalModel> _sugerencias = [];
  bool _isLoading = false;

  List<EjercicioGlobalModel> get sugerencias => _sugerencias;
  bool get isLoading => _isLoading;


  Future<void> cargarEjercicios() async {
    if (_todos.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    _todos = await _service.fetchEjercicios();

    _isLoading = false;
    notifyListeners();
  }

  void buscar(String query) {
    final q = _normalizar(query.trim());

    if (q.isEmpty) {
      _sugerencias = [];
    } else {
      _sugerencias = _todos
          .where((e) => _normalizar(e.nombre).contains(q))
          .take(5) // Máximo 5 sugerencias visibles
          .toList();
    }
    notifyListeners();
  }

  void limpiarSugerenciasSilencioso() {
    _sugerencias = [];
  }

  void limpiarSugerencias() {
    _sugerencias = [];
    notifyListeners();
  }

  EjercicioGlobalModel? buscarPorNombre(String nombre) {
    final n = _normalizar(nombre.trim());
    try {
      return _todos.firstWhere((e) => _normalizar(e.nombre) == n);
    } catch (_) {
      return null;
    }
  }

  // minúsculas + quita tildes
  String _normalizar(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }
}