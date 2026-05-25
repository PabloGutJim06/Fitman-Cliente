import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine_model.dart';
import '../models/registro_model.dart';

class HiveBoxes {
  static const String rutinas = 'rutinas_cache';
  static const String registros = 'registros_cache';
  static const String pendientes = 'registros_pendientes';
}

class PendingRegistro {
  final String rutinaId;
  final String rutinaNombre;
  final int numEjercicios;
  final DateTime fecha;

  PendingRegistro({
    required this.rutinaId,
    required this.rutinaNombre,
    required this.numEjercicios,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
    'rutina_id': rutinaId,
    'rutina_nombre': rutinaNombre,
    'num_ejercicios': numEjercicios,
    'fecha': fecha.toIso8601String(),
  };

  factory PendingRegistro.fromJson(Map<String, dynamic> json) =>
      PendingRegistro(
        rutinaId: json['rutina_id'],
        rutinaNombre: json['rutina_nombre'],
        numEjercicios: json['num_ejercicios'],
        fecha: DateTime.parse(json['fecha']),
      );
}

class HiveService {

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(HiveBoxes.rutinas);
    await Hive.openBox<String>(HiveBoxes.registros);
    await Hive.openBox<String>(HiveBoxes.pendientes);
    debugPrint('Hive inicializado correctamente');
  }

  Future<void> guardarRutinas(List<RoutineModel> rutinas) async {
    final box = Hive.box<String>(HiveBoxes.rutinas);
    await box.clear();
    for (final rutina in rutinas) {
      if (rutina.id != null) {
        await box.put(rutina.id!, jsonEncode(rutina.toJsonCompleto()));
      }
    }
    debugPrint('Hive: ${rutinas.length} rutinas guardadas en caché');
  }

  List<RoutineModel> cargarRutinas() {
    final box = Hive.box<String>(HiveBoxes.rutinas);
    if (box.isEmpty) return [];
    return box.values
        .map((json) => RoutineModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> guardarRegistros(List<RegistroModel> registros) async {
    final box = Hive.box<String>(HiveBoxes.registros);
    await box.clear();
    for (final registro in registros) {
      await box.put(registro.id, jsonEncode(_registroToJson(registro)));
    }
    debugPrint('Hive: ${registros.length} registros guardados en caché');
  }

  List<RegistroModel> cargarRegistros() {
    final box = Hive.box<String>(HiveBoxes.registros);
    if (box.isEmpty) return [];
    return box.values
        .map((json) => RegistroModel.fromJson(jsonDecode(json)))
        .toList();
  }


  Future<void> encolarRegistro(PendingRegistro registro) async {
    final box = Hive.box<String>(HiveBoxes.pendientes);
    final key = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    await box.put(key, jsonEncode(registro.toJson()));
    debugPrint('Hive: registro encolado para sync (${box.length} pendientes)');
  }

  List<MapEntry<String, PendingRegistro>> cargarPendientes() {
    final box = Hive.box<String>(HiveBoxes.pendientes);
    return box.keys
        .cast<String>()
        .map((key) => MapEntry(
      key,
      PendingRegistro.fromJson(jsonDecode(box.get(key)!)),
    ))
        .toList();
  }

  Future<void> eliminarPendiente(String key) async {
    await Hive.box<String>(HiveBoxes.pendientes).delete(key);
  }

  int get totalPendientes =>
      Hive.box<String>(HiveBoxes.pendientes).length;

  Future<void> limpiarTodo() async {
    await Hive.box<String>(HiveBoxes.rutinas).clear();
    await Hive.box<String>(HiveBoxes.registros).clear();
    await Hive.box<String>(HiveBoxes.pendientes).clear();
    debugPrint('Hive: caché limpiada al cerrar sesión');
  }

  Map<String, dynamic> _registroToJson(RegistroModel r) => {
    'id': r.id,
    'rutina_id': r.rutinaId,
    'rutina_nombre': r.rutinaNombre,
    'num_ejercicios': r.numEjercicios,
    'usuario_id': r.usuarioId,
    'fecha': r.fecha.toIso8601String(),
    if (r.notas != null) 'notas': r.notas,
  };

  static const String _avatarKey = 'avatar_path';

  Future<void> guardarAvatarPath(String path) async {
    final box = Hive.box<String>(HiveBoxes.rutinas);
    await box.put(_avatarKey, path);
    debugPrint('Hive: avatar guardado en $path');
  }

  String? cargarAvatarPath() {
    final box = Hive.box<String>(HiveBoxes.rutinas);
    return box.get(_avatarKey);
  }

  Future<void> eliminarAvatar() async {
    final box = Hive.box<String>(HiveBoxes.rutinas);
    await box.delete(_avatarKey);
  }
}