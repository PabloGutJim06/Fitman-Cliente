// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

class ExerciseModel {
  String nombre;
  String descripcion;
  int duracion;
  int series;
  int repeticiones;
  int descansoSegundos;

  ExerciseModel({
    required this.nombre,
    this.descripcion = "",
    this.duracion = 0,
    this.series = 0,
    this.repeticiones = 0,
    this.descansoSegundos = 0,
  });

  bool get isDescanso => duracion > 0 && series == 0 && repeticiones == 0;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
    nombre: json['nombre'],
    descripcion: json['descripcion'] ?? "",
    duracion: json['duracion'] ?? 0,
    series: json['series'] ?? 0,
    repeticiones: json['repeticiones'] ?? 0,
    descansoSegundos: json['descanso_segundos'] ?? 0,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "nombre": nombre,
      "duracion": duracion,
      "series": series,
      "repeticiones": repeticiones,
    };
    if (descripcion.isNotEmpty) {
      map["descripcion"] = descripcion;
    }
    return map;
  }
// ✅ Cierre de ExerciseModel
}

class RoutineModel {
  String nombre;
  final String? id;
  List<ExerciseModel> ejercicios;

  RoutineModel({this.id, required this.nombre, required this.ejercicios});

  factory RoutineModel.fromJson(Map<String, dynamic> json) => RoutineModel(
    id: json['_id'] ?? json['id'],
    nombre: json['rutina_nombre'],
    ejercicios: (json['ejercicios'] as List)
        .map((e) => ExerciseModel.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "rutina_nombre": nombre,
    "ejercicios": ejercicios.map((e) => e.toJson()).toList(),
  };
}