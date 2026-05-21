import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/hive_service.dart';
import '../services/sync_service.dart';

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

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    await HiveService().limpiarTodo();
    SyncService().detener();
    _user = null;

    _isLoading = false;
    notifyListeners();
  }
}