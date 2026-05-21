class EjercicioGlobalModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String grupoMuscular;
  final String? nivelDificultad;

  const EjercicioGlobalModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.grupoMuscular,
    this.nivelDificultad,
  });

  factory EjercicioGlobalModel.fromJson(Map<String, dynamic> json) {
    return EjercicioGlobalModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      grupoMuscular: json['grupo_muscular'] ?? '',
      nivelDificultad: json['nivel_dificultad'] as String?,
    );
  }
}