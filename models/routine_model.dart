class ColaboradorModel {
  final String usuarioId;
  final String nombre;
  final String email;
  final bool puedeEditar;

  const ColaboradorModel({
    required this.usuarioId,
    required this.nombre,
    required this.email,
    required this.puedeEditar,
  });

  factory ColaboradorModel.fromJson(Map<String, dynamic> json) {
    return ColaboradorModel(
      usuarioId: json['usuario_id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      puedeEditar: json['puede_editar'] ?? false,
    );
  }
}

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
}

class RoutineModel {
  String nombre;
  final String? id;
  List<ExerciseModel> ejercicios;

  final bool esCreador;
  final bool puedeEditar;
  final List<ColaboradorModel> colaboradores;

  RoutineModel({
    this.id,
    required this.nombre,
    required this.ejercicios,
    this.esCreador = true,
    this.puedeEditar = true,
    this.colaboradores = const [],
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) => RoutineModel(
    id: json['_id'] ?? json['id'],
    nombre: json['rutina_nombre'],
    ejercicios: (json['ejercicios'] as List)
        .map((e) => ExerciseModel.fromJson(e))
        .toList(),
    esCreador: json['es_creador'] ?? true,
    puedeEditar: json['puede_editar'] ?? true,
    colaboradores: json['colaboradores'] != null
        ? (json['colaboradores'] as List)
        .map((c) => ColaboradorModel.fromJson(c))
        .toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    "rutina_nombre": nombre,
    "ejercicios": ejercicios.map((e) => e.toJson()).toList(),
  };

  bool get tienePermisoEdicion => esCreador || puedeEditar;

  Map<String, dynamic> toJsonCompleto() => {
    'id': id,
    'rutina_nombre': nombre,
    'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
    'es_creador': esCreador,
    'puede_editar': puedeEditar,
    'colaboradores': colaboradores
        .map((c) => {
      'usuario_id': c.usuarioId,
      'nombre': c.nombre,
      'email': c.email,
      'puede_editar': c.puedeEditar,
    })
        .toList(),
  };

}