import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ─── Datos del formulario ─── //
  String nombre = '';
  String email = '';
  String password = '';
  int? edad;
  double? pesoActual;
  double? altura;
  String? objetivo;
  String? nivel;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get paso1Valido =>
      nombre.trim().isNotEmpty &&
          email.trim().isNotEmpty &&
          email.contains('@') &&
          password.length >= 6;

  bool get paso2Valido => true;
  bool get paso3Valido => true;

  void actualizarPaso1({
    String? nombre,
    String? email,
    String? password,
  }) {
    if (nombre != null) this.nombre = nombre;
    if (email != null) this.email = email;
    if (password != null) this.password = password;
    notifyListeners();
  }

  void actualizarPaso2({int? edad, double? pesoActual, double? altura}) {
    this.edad = edad;
    this.pesoActual = pesoActual;
    this.altura = altura;
    notifyListeners();
  }

  void seleccionarObjetivo(String? obj) {
    objetivo = obj;
    notifyListeners();
  }

  void seleccionarNivel(String? niv) {
    nivel = niv;
    notifyListeners();
  }

  Future<bool> registrar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.register(
        nombre: nombre.trim(),
        email: email.trim(),
        password: password,
        edad: edad,
        pesoActual: pesoActual,
        altura: altura,
        objetivo: objetivo,
        nivel: nivel,
      );

      // ✅ TEMPORAL — para diagnosticar
      debugPrint('Register result: $success');
      debugPrint('Email usado: ${email.trim()}');

      if (!success) {
        _errorMessage = 'No se pudo crear la cuenta. El email puede estar en uso.';
      }

      return success;
    } catch (e) {
      // ✅ TEMPORAL
      debugPrint('Register exception: $e');
      _errorMessage = 'Error de conexión. Inténtalo de nuevo.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}