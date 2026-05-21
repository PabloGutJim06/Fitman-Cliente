import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.fetchMe(token);
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
      _errorMessage = 'No se pudo cargar el perfil.';

      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}