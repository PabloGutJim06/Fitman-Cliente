class RegistroModel {
  final String id;
  final String rutinaId;
  final String rutinaNombre;
  final int numEjercicios;
  final String? notas;
  final String usuarioId;
  final DateTime fecha;

  RegistroModel({
    required this.id,
    required this.rutinaId,
    required this.rutinaNombre,
    required this.numEjercicios,
    this.notas,
    required this.usuarioId,
    required this.fecha,
  });

  factory RegistroModel.fromJson(Map<String, dynamic> json) {
    return RegistroModel(
      id: json['id']?.toString() ?? '',
      rutinaId: json['rutina_id'] ?? '',
      rutinaNombre: json['rutina_nombre'] ?? '',
      numEjercicios: json['num_ejercicios'] ?? 0,
      notas: json['notas'] as String?,
      usuarioId: json['usuario_id'] ?? '',
      fecha: DateTime.parse(json['fecha']),
    );
  }
}