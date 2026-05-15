// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _user;
  UserModel? get user => _user;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);

    _isLoading = false;

    if (result != null) {
      _user = result;
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<bool> checkSession() async {
    if (_isLoading) return false;

    // Síncrono: sin microtask, sin race condition
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getStoredToken();

      if (token != null) {
        final userResponse = await _userService.fetchMe(token);
        _user = userResponse;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Sesión inválida o expirada: $e');
      await _authService.logout();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ← NUEVO: El método que ProfileScreen estaba buscando
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout(); // Borra el token de la caja fuerte
    _user = null;                // Limpiamos el usuario en memoria

    _isLoading = false;
    notifyListeners();
  }
}