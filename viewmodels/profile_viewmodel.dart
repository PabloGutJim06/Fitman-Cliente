import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/hive_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final HiveService _hive = HiveService();
  final ImagePicker _picker = ImagePicker();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _avatarPath;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get avatarPath => _avatarPath;

  File? get avatarFile {
    if (_avatarPath == null) return null;
    final file = File(_avatarPath!);
    return file.existsSync() ? file : null;
  }

  Future<void> loadUserProfile(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.fetchMe(token);
      _avatarPath = _hive.cargarAvatarPath();
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
      _errorMessage = 'No se pudo cargar el perfil.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cambiarAvatar() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (picked == null) return; // Usuario canceló
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'avatar_${_user?.id ?? 'user'}.jpg';
      final destino = File(path.join(appDir.path, fileName));
      await File(picked.path).copy(destino.path);

      await _hive.guardarAvatarPath(destino.path);
      _avatarPath = destino.path;
      notifyListeners();

      debugPrint('Avatar guardado en ${destino.path}');
    } catch (e) {
      debugPrint('Error al cambiar avatar: $e');
    }
  }

  Future<void> eliminarAvatar() async {
    if (_avatarPath != null) {
      final file = File(_avatarPath!);
      if (file.existsSync()) await file.delete();
      await _hive.eliminarAvatar();
      _avatarPath = null;
      notifyListeners();
    }
  }
}