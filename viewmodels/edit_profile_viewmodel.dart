import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  String nombre = '';
  int? edad;
  double? pesoActual;
  double? altura;
  String? objetivo;
  String? nivel;

  bool _isLoading = false;
  bool _guardadoExitoso = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get guardadoExitoso => _guardadoExitoso;
  String? get errorMessage => _errorMessage;

  void inicializar(UserModel user) {
    nombre = user.nombre;
    edad = user.edad;
    pesoActual = user.pesoActual;
    altura = user.altura;
    objetivo = user.objetivo;
    nivel = user.nivel;
    _guardadoExitoso = false;
    _errorMessage = null;
  }

  void actualizarNombre(String v) {
    nombre = v;
    notifyListeners();
  }

  void actualizarEdad(String v) {
    edad = int.tryParse(v);
    notifyListeners();
  }

  void actualizarPeso(String v) {
    pesoActual = double.tryParse(v);
    notifyListeners();
  }

  void actualizarAltura(String v) {
    altura = double.tryParse(v);
    notifyListeners();
  }

  void seleccionarNivel(String? v) {
    nivel = nivel == v ? null : v;
    notifyListeners();
  }

  void seleccionarObjetivo(String? v) {
    objetivo = objetivo == v ? null : v;
    notifyListeners();
  }

  bool get formularioValido => nombre.trim().isNotEmpty;

  Future<bool> guardar(String token) async {
    if (!formularioValido) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{
        'nombre': nombre.trim(),
      };
      if (edad != null) body['edad'] = edad;
      if (pesoActual != null) body['peso_actual'] = pesoActual;
      if (altura != null) body['altura'] = altura;
      if (objetivo != null) body['objetivo'] = objetivo;
      if (nivel != null) body['nivel'] = nivel;

      final success = await _userService.patchMe(token, body);

      if (success) {
        _guardadoExitoso = true;
      } else {
        _errorMessage = 'No se pudieron guardar los cambios.';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error de conexión. Inténtalo de nuevo.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}